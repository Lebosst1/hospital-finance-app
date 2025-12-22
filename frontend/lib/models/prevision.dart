// lib/models/prevision.dart
class Prevision {
  final int? idPrevision;
  final double coutPrevu;
  final String dateCalcul; // ex : "2025-01-01"
  final int? idService;
  final String? nomService;

  Prevision({
    this.idPrevision,
    required this.coutPrevu,
    required this.dateCalcul,
    this.idService,
    this.nomService,
  });

  factory Prevision.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>?;

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Prevision(
      idPrevision: json['idPrevision'] as int?,
      coutPrevu: _toDouble(json['coutPrevu']),
      dateCalcul: json['dateCalcul']?.toString() ?? '',
      idService: service?['idService'] as int?,
      nomService: service?['nomService']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPrevision': idPrevision,
      'coutPrevu': coutPrevu,
      'dateCalcul': dateCalcul,
      'service': idService != null ? {'idService': idService} : null,
    };
  }
}
