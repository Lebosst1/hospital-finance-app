class ServiceHospitalier {
  final int? idService;
  final String nomService;
  final double? budgetMensuel;
  final double? budgetAnnuel;
  final double? seuilAlerte;

  ServiceHospitalier({
    this.idService,
    required this.nomService,
    this.budgetMensuel,
    this.budgetAnnuel,
    this.seuilAlerte,
  });

  factory ServiceHospitalier.fromJson(Map<String, dynamic> json) {
    return ServiceHospitalier(
      idService: json['idService'] as int?,
      nomService: json['nomService'] as String,
      budgetMensuel: (json['budgetMensuel'] as num?)?.toDouble(),
      budgetAnnuel: (json['budgetAnnuel'] as num?)?.toDouble(),
      seuilAlerte: (json['seuilAlerte'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idService': idService,
      'nomService': nomService,
      'budgetMensuel': budgetMensuel,
      'budgetAnnuel': budgetAnnuel,
      'seuilAlerte': seuilAlerte,
    };
  }

  ServiceHospitalier copyWith({
    int? idService,
    String? nomService,
    double? budgetMensuel,
    double? budgetAnnuel,
    double? seuilAlerte,
  }) {
    return ServiceHospitalier(
      idService: idService ?? this.idService,
      nomService: nomService ?? this.nomService,
      budgetMensuel: budgetMensuel ?? this.budgetMensuel,
      budgetAnnuel: budgetAnnuel ?? this.budgetAnnuel,
      seuilAlerte: seuilAlerte ?? this.seuilAlerte,
    );
  }
}
