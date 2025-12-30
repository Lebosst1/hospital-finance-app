from fastapi import FastAPI, Request
from pydantic import BaseModel
from typing import List, Optional, Dict
import numpy as np
import pandas as pd
import os


app = FastAPI()

# Charger le dataset global au démarrage
DATASET_PATH = os.path.join(os.path.dirname(__file__), "hospital_finance_data.csv")
if os.path.exists(DATASET_PATH):
    finance_df = pd.read_csv(DATASET_PATH)
else:
    finance_df = pd.DataFrame(columns=["service", "year", "month", "expense"])

class ServiceData(BaseModel):
    nom: str
    budget_mensuel: float
    budget_annuel: float
    historique_depenses: Optional[List[float]] = None  # 12 derniers mois

class AlerteData(BaseModel):
    type: str
    message: str
    niveau: str
    status: str
    dateAlerte: Optional[str] = None

class AnalyseRequest(BaseModel):
    services: List[ServiceData]
    alertes: Optional[List[AlerteData]] = None

class AnalyseResult(BaseModel):
    nom: str
    depense_prevue: float
    alerte: Optional[str]
    conseil: Optional[str]
    tendance: Optional[str]


class AnalyseParPeriode(BaseModel):
    par_mois: Dict[str, float]  # ex: {"2024-01": 12000.0}
    par_annee: Dict[str, float] # ex: {"2024": 36000.0}

class AnalyseGlobalResult(BaseModel):
    total_depense_prevue: float
    alertes: List[str]
    conseils: List[str]
    tendances: List[str]
    details: List[AnalyseResult]
    global_par_mois: Optional[Dict[str, float]] = None
    global_par_annee: Optional[Dict[str, float]] = None
    par_service_par_mois: Optional[Dict[str, Dict[str, float]]] = None
    par_service_par_annee: Optional[Dict[str, Dict[str, float]]] = None


@app.post("/analyse", response_model=AnalyseGlobalResult)
def analyse_finances(req: AnalyseRequest):
    alertes = []
    conseils = []
    tendances = []
    details = []
    total_prevu = 0.0

    # --- Prendre en compte les alertes transmises (si présentes) ---
    alertes_ia = []
    if req.alertes:
        for a in req.alertes:
            alertes_ia.append(f"Alerte utilisateur: [{a.niveau}] {a.type} - {a.message} (statut: {a.status})")

    # --- Analyse par service (prévision, tendance, alertes) ---
    for s in req.services:
        # Prévision simple : moyenne des historiques ou budget mensuel
        if s.historique_depenses and len(s.historique_depenses) >= 3:
            prevu = float(np.mean(s.historique_depenses[-3:]))
            tendance_val = np.polyfit(range(len(s.historique_depenses)), s.historique_depenses, 1)[0]
            tendance = "en hausse" if tendance_val > 0 else ("en baisse" if tendance_val < 0 else "stable")
        else:
            # Si pas d'historique, utiliser le dataset CSV si dispo
            if not finance_df.empty and s.nom in finance_df['service'].values:
                histo = finance_df[finance_df['service'] == s.nom]['expense'].values
                if len(histo) >= 3:
                    prevu = float(np.mean(histo[-3:]))
                    tendance_val = np.polyfit(range(len(histo)), histo, 1)[0]
                    tendance = "en hausse" if tendance_val > 0 else ("en baisse" if tendance_val < 0 else "stable")
                else:
                    prevu = s.budget_mensuel
                    tendance = "données insuffisantes"
            else:
                prevu = s.budget_mensuel
                tendance = "données insuffisantes"
        total_prevu += prevu
        alerte = None
        conseil = None
        if prevu > s.budget_mensuel * 1.1:
            alerte = f"Dépenses prévues supérieures au budget mensuel pour {s.nom}"
            alertes.append(alerte)
            conseil = "Réduire les dépenses ou augmenter le budget."
            conseils.append(conseil)

    # Ajouter les alertes utilisateur à la liste globale
    if alertes_ia:
        alertes.extend(alertes_ia)
        details.append(AnalyseResult(
            nom=s.nom,
            depense_prevue=round(prevu, 2),
            alerte=alerte,
            conseil=conseil,
            tendance=tendance
        ))
        tendances.append(f"{s.nom}: {tendance}")

    # --- Analyse globale par mois et par année ---
    global_par_mois = {}
    global_par_annee = {}
    par_service_par_mois = {}
    par_service_par_annee = {}
    if not finance_df.empty:
        # Global par mois
        mois_group = finance_df.groupby(['year', 'month'])['expense'].sum().reset_index()
        for _, row in mois_group.iterrows():
            key = f"{int(row['year'])}-{int(row['month']):02d}"
            global_par_mois[key] = float(row['expense'])
        # Global par année
        annee_group = finance_df.groupby(['year'])['expense'].sum().reset_index()
        for _, row in annee_group.iterrows():
            key = f"{int(row['year'])}"
            global_par_annee[key] = float(row['expense'])
        # Par service par mois
        for service in finance_df['service'].unique():
            df_s = finance_df[finance_df['service'] == service]
            mois_s = df_s.groupby(['year', 'month'])['expense'].sum().reset_index()
            par_service_par_mois[service] = {f"{int(r['year'])}-{int(r['month']):02d}": float(r['expense']) for _, r in mois_s.iterrows()}
            annee_s = df_s.groupby(['year'])['expense'].sum().reset_index()
            par_service_par_annee[service] = {f"{int(r['year'])}": float(r['expense']) for _, r in annee_s.iterrows()}

    return AnalyseGlobalResult(
        total_depense_prevue=round(total_prevu, 2),
        alertes=alertes,
        conseils=conseils,
        tendances=tendances,
        details=details,
        global_par_mois=global_par_mois,
        global_par_annee=global_par_annee,
        par_service_par_mois=par_service_par_mois,
        par_service_par_annee=par_service_par_annee
    )

# Pour lancer : uvicorn main:app --reload
