// lib/models/alerte.dart
class Alerte {
  final int? idAlerte;
  final String message;
  final String niveau; // ex : "INFO", "WARNING", "CRITIQUE"
  final String dateAlerte;
  final int? idService;
  final String? nomService;

  Alerte({
    this.idAlerte,
    required this.message,
    required this.niveau,
    required this.dateAlerte,
    this.idService,
    this.nomService,
  });

  factory Alerte.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>?;

    return Alerte(
      idAlerte: json['idAlerte'] as int?,
      message: json['message']?.toString() ?? '',
      niveau: json['niveau']?.toString() ?? 'INFO',
      dateAlerte: json['dateAlerte']?.toString() ?? '',
      idService: service?['idService'] as int?,
      nomService: service?['nomService']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAlerte': idAlerte,
      'message': message,
      'niveau': niveau,
      'dateAlerte': dateAlerte,
      'service': idService != null ? {'idService': idService} : null,
    };
  }
}
