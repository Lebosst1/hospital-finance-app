// lib/models/alerte.dart
class Alerte {
  final int? idAlerte;
  final String type;
  final String message;
  final String niveau; // ex : "INFO", "WARNING", "CRITIQUE"
  final String dateAlerte;
  final int? idService;
  final String? nomService;
  final String statut; // NOUVELLE, VALIDEE, EN_COURS, RESOLUE

  Alerte({
    this.idAlerte,
    required this.type,
    required this.message,
    required this.niveau,
    required this.dateAlerte,
    this.idService,
    this.nomService,
    this.statut = 'NOUVELLE',
  });

  factory Alerte.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>?;

    return Alerte(
      idAlerte: json['idAlerte'] as int?,
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      niveau: json['niveau']?.toString() ?? 'INFO',
      dateAlerte: json['dateAlerte']?.toString() ?? '',
      idService: service?['idService'] as int?,
      nomService: service?['nomService']?.toString(),
      statut: json['status']?.toString() ?? json['statut']?.toString() ?? 'NOUVELLE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAlerte': idAlerte,
      'type': type,
      'message': message,
      'niveau': niveau,
      'dateAlerte': dateAlerte,
      'status': statut,
      'service': idService != null ? {'idService': idService} : null,
    };
  }
}
