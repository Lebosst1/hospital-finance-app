# Copilot Instructions for hospital-finance-app

## Overview
This monorepo contains a hospital finance management system with three main components:

- **backend/**: Java Spring Boot REST API for hospital finance, patient, and service management. Connects to MySQL. Key entry: `HospitalFinanceDashboardApplication.java`.
- **ai_finance_service/**: Python FastAPI microservice for financial analysis and forecasting, using `hospital_finance_data.csv` as its dataset. Key entry: `main.py`.
- **frontend/**: Flutter web/mobile app for dashboards, login, and user interaction. Key entry: `lib/main.dart`.

## Architecture & Data Flow
- The **frontend** communicates with the **backend** (Spring Boot) via REST endpoints (see `controller/`), and may call the **ai_finance_service** for advanced analytics.
- The **backend** manages authentication (JWT), business logic, and persistence (JPA, MySQL). Service boundaries are defined by `controller/`, `service/`, and `entity/` packages.
- The **ai_finance_service** is a stateless analytics API, loaded with CSV data at startup, and exposes `/analyse` endpoints.

## Developer Workflows
- **Backend**:
  - Build: `./mvnw clean package` (or `mvnw.cmd` on Windows)
  - Run: `./mvnw spring-boot:run` (port 8081, see `application.properties`)
  - Test: `./mvnw test`
  - DB: MySQL, auto-creates schema if missing
- **AI Service**:
  - Run: `uvicorn main:app --reload` in `ai_finance_service/`
  - Data: Update `hospital_finance_data.csv` for new analytics
- **Frontend**:
  - Run: `flutter run -d chrome` (web) or `flutter run` (mobile)
  - Build: `flutter build web`

## Project-Specific Conventions
- **Backend**:
  - All REST endpoints are under `/api/` (see `controller/`).
  - JWT secret and DB config in `application.properties`.
  - Service logic is split into `service/` (interfaces) and `service/impl/` (implementations).
- **AI Service**:
  - Expects input as JSON matching `AnalyseRequest` schema.
  - Returns predictions, alerts, and advice per service.
- **Frontend**:
  - Uses named routes (see `main.dart`).
  - Models and screens are organized in `models/` and `screens/`.

## Integration Points
- **Backend ↔ AI Service**: Likely via HTTP calls from backend service (see `FinanceAIController.java` if present).
- **Frontend ↔ Backend**: Uses HTTP, see `services/` in frontend for API clients.

## Examples
- To add a new finance analysis, extend `AnalyseFinanceService` and expose via a new controller endpoint.
- To add a new dashboard widget, create a new screen in `frontend/lib/screens/` and register its route in `main.dart`.

---
For more details, see the respective `README.md` files or key entrypoints in each component.
