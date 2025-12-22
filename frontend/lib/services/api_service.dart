// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';
import '../models/service_hospitalier.dart';
import '../models/sejour.dart';
import '../models/patient.dart';
import '../models/prevision.dart';
import '../models/alerte.dart';

class ApiService {
  // 🔗 URL de base du backend
  static const String baseUrl = 'http://localhost:8080';

  // ===============================
  //   GESTION DU TOKEN / HEADERS
  // ===============================
  static Future<String?> _getTokenInternal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> _buildHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (withAuth) {
      final token = await _getTokenInternal();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // 🔁 Petit alias pour le code qui utilise _authHeaders()
  static Future<Map<String, String>> _authHeaders() => _buildHeaders();

  static Exception _buildError(http.Response response) {
    String message = 'Erreur HTTP ${response.statusCode}';

    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      } else if (body is String) {
        message = body;
      }
    } catch (_) {}

    return Exception(message);
  }

  // ===============================
  //          AUTHENTICATION
  // ===============================
  static Future<AuthResponse> login(AuthRequest request) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: await _buildHeaders(withAuth: false),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', authResponse.token);

      return authResponse;
    } else {
      throw _buildError(response);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<String?> getToken() => _getTokenInternal();

  // ===============================
  //       SERVICES HOSPITALIERS
  // ===============================

  static Future<List<ServiceHospitalier>> getServices() async {
    final url = Uri.parse('$baseUrl/services/all');

    final response = await http.get(
      url,
      headers: await _buildHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => ServiceHospitalier.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw _buildError(response);
    }
  }

  static Future<ServiceHospitalier> createService(
      ServiceHospitalier service) async {
    final url = Uri.parse('$baseUrl/services/add');

    final response = await http.post(
      url,
      headers: await _buildHeaders(),
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ServiceHospitalier.fromJson(data);
    } else {
      throw _buildError(response);
    }
  }

  static Future<ServiceHospitalier> updateService(
      ServiceHospitalier service) async {
    if (service.idService == null) {
      throw Exception("idService manquant pour la mise à jour");
    }

    final url = Uri.parse('$baseUrl/services/${service.idService}');

    final response = await http.put(
      url,
      headers: await _buildHeaders(),
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ServiceHospitalier.fromJson(data);
    } else {
      throw _buildError(response);
    }
  }

  static Future<void> deleteService(int idService) async {
    final url = Uri.parse('$baseUrl/services/$idService');

    final response = await http.delete(
      url,
      headers: await _buildHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw _buildError(response);
    }
  }

  // ===============================
  //              SEJOURS
  // ===============================

  static Future<List<Sejour>> getSejours() async {
    final url = Uri.parse('$baseUrl/sejour/all');

    final response = await http.get(
      url,
      headers: await _buildHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Sejour.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw _buildError(response);
    }
  }

  static Future<Sejour> createSejour(Sejour sejour) async {
    final url = Uri.parse('$baseUrl/sejour/add');

    final response = await http.post(
      url,
      headers: await _buildHeaders(),
      body: jsonEncode(sejour.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Sejour.fromJson(data);
    } else {
      throw _buildError(response);
    }
  }

  static Future<Sejour> updateSejour(Sejour sejour) async {
    if (sejour.idSejour == null) {
      throw Exception("idSejour manquant pour la mise à jour");
    }

    final url = Uri.parse('$baseUrl/sejour/${sejour.idSejour}');

    final response = await http.put(
      url,
      headers: await _buildHeaders(),
      body: jsonEncode(sejour.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Sejour.fromJson(data);
    } else {
      throw _buildError(response);
    }
  }

  static Future<void> deleteSejour(int idSejour) async {
    final url = Uri.parse('$baseUrl/sejour/$idSejour');

    final response = await http.delete(
      url,
      headers: await _buildHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw _buildError(response);
    }
  }

  // ===============================
  //              PATIENTS
  // ===============================

  static Future<List<Patient>> getPatients() async {
    final url = Uri.parse('$baseUrl/patient/all');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur chargement patients (${response.statusCode})');
    }
  }

  static Future<Patient> createPatient(Patient patient) async {
    final url = Uri.parse('$baseUrl/patient/add');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(patient.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Patient.fromJson(json);
    } else {
      throw Exception('Erreur création patient (${response.statusCode})');
    }
  }

  static Future<Patient> updatePatient(Patient patient) async {
    if (patient.idPatient == null) {
      throw Exception('idPatient manquant pour la mise à jour');
    }

    final url = Uri.parse('$baseUrl/patient/${patient.idPatient}');
    final headers = await _authHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(patient.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Patient.fromJson(json);
    } else {
      throw Exception('Erreur mise à jour patient (${response.statusCode})');
    }
  }

  static Future<void> deletePatient(int id) async {
    final url = Uri.parse('$baseUrl/patient/$id');
    final headers = await _authHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erreur suppression patient (${response.statusCode})');
    }
  }

  // ===============================
  //             PREVISIONS
  // ===============================

  static Future<List<Prevision>> getPrevisions() async {
    final url = Uri.parse('$baseUrl/prevision/all');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => Prevision.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur chargement prévisions (${response.statusCode})');
    }
  }

  static Future<Prevision> createPrevision(Prevision prev) async {
    final url = Uri.parse('$baseUrl/prevision/add');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(prev.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Prevision.fromJson(json);
    } else {
      throw Exception('Erreur création prévision (${response.statusCode})');
    }
  }

  static Future<Prevision> updatePrevision(Prevision prev) async {
    if (prev.idPrevision == null) {
      throw Exception('idPrevision manquant pour la mise à jour');
    }

    final url = Uri.parse('$baseUrl/prevision/${prev.idPrevision}');
    final headers = await _authHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(prev.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Prevision.fromJson(json);
    } else {
      throw Exception('Erreur mise à jour prévision (${response.statusCode})');
    }
  }

  static Future<void> deletePrevision(int idPrevision) async {
    final url = Uri.parse('$baseUrl/prevision/$idPrevision');
    final headers = await _authHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erreur suppression prévision (${response.statusCode})');
    }
  }

  // ===============================
  //              ALERTES
  // ===============================

  static Future<List<Alerte>> getAlertes() async {
    final url = Uri.parse('$baseUrl/alerte/all');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => Alerte.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur chargement alertes (${response.statusCode})');
    }
  }

  static Future<Alerte> createAlerte(Alerte alerte) async {
    final url = Uri.parse('$baseUrl/alerte/add');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(alerte.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Alerte.fromJson(json);
    } else {
      throw Exception('Erreur création alerte (${response.statusCode})');
    }
  }

  static Future<void> deleteAlerte(int idAlerte) async {
    final url = Uri.parse('$baseUrl/alerte/$idAlerte');
    final headers = await _authHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erreur suppression alerte (${response.statusCode})');
    }
  }



     // ===============================
  //         INFOS UTILISATEUR
  // ===============================

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }





}
