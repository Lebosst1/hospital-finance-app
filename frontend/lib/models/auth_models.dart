// lib/models/auth_models.dart

class AuthRequest {
  final String email;
  final String password;

  AuthRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class AuthResponse {
  final String token;
  final String role;
  final String nom;
  final String prenom;

  AuthResponse({
    required this.token,
    required this.role,
    required this.nom,
    required this.prenom,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      role: (json['role'] ?? 'USER') as String,
      nom: (json['nom'] ?? '') as String,
      prenom: (json['prenom'] ?? '') as String,
    );
  }
}
