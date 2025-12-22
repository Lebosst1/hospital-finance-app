// lib/models/patient.dart

class Patient {
  final int? idPatient;
  final String nom;
  final String prenom;
  final String? sexe;          // "H" ou "F"
  final String? telephone;
  final String? adresse;
  final String? dateNaissance; // format "yyyy-MM-dd" côté Flutter

  Patient({
    this.idPatient,
    required this.nom,
    required this.prenom,
    this.sexe,
    this.telephone,
    this.adresse,
    this.dateNaissance,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      idPatient: json['idPatient'] as int?,
      nom: (json['nom'] ?? '') as String,
      prenom: (json['prenom'] ?? '') as String,
      sexe: json['sexe'] as String?,
      telephone: json['telephone'] as String?,
      adresse: json['adresse'] as String?,
      // Jackson renverra normalement "dateNaissance": "2025-12-15"
      dateNaissance: json['dateNaissance'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPatient': idPatient,
      'nom': nom,
      'prenom': prenom,
      'sexe': sexe,
      'telephone': telephone,
      'adresse': adresse,
      'dateNaissance': dateNaissance,
    };
  }

  String get fullName => '$prenom $nom';
}
