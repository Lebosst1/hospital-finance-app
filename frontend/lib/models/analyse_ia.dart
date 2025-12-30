class AnalyseIA {
  final double depensePrevue;
  final String? alerte;
  final String? conseil;
  final String? tendance;

  AnalyseIA({
    required this.depensePrevue,
    this.alerte,
    this.conseil,
    this.tendance,
  });

  factory AnalyseIA.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as List?;
    final first = (details != null && details.isNotEmpty) ? details[0] : {};
    return AnalyseIA(
      depensePrevue: (first['depense_prevue'] ?? 0).toDouble(),
      alerte: first['alerte'],
      conseil: first['conseil'],
      tendance: first['tendance'],
    );
  }
}
