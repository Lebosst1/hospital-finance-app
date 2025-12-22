// lib/models/sejour.dart

class Sejour {
  final int? idSejour;
  final int nbJours;
  final double? cout;
  final String? dateEntree; // "yyyy-MM-dd"
  final String? dateSortie; // "yyyy-MM-dd"

  /// Relations
  final int? idService;
  final int? idPatient;

  Sejour({
    this.idSejour,
    required this.nbJours,
    this.cout,
    this.dateEntree,
    this.dateSortie,
    this.idService,
    this.idPatient,
  });

  factory Sejour.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>?;
    final patient = json['patient'] as Map<String, dynamic>?;

    return Sejour(
      idSejour: json['idSejour'] as int?,
      nbJours: (json['nbJours'] ?? 0) as int,
      cout: (json['cout'] as num?)?.toDouble(),
      dateEntree: json['dateEntree'] as String?,
      dateSortie: json['dateSortie'] as String?,
      idService: service != null ? service['idService'] as int? : null,
      idPatient: patient != null ? patient['idPatient'] as int? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSejour': idSejour,
      'nbJours': nbJours,
      'cout': cout,
      'dateEntree': dateEntree,
      'dateSortie': dateSortie,
      // On envoie seulement les id dans des sous-objets
      'service': idService != null ? {'idService': idService} : null,
      'patient': idPatient != null ? {'idPatient': idPatient} : null,
    }..removeWhere((key, value) => value == null);
  }
}
