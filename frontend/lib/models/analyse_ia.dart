class AnalyseIA {
  final int score;
  final String niveauRisque;
  final String resume;
  final String conseil;

  AnalyseIA({
    required this.score,
    required this.niveauRisque,
    required this.resume,
    required this.conseil,
  });

  factory AnalyseIA.fromJson(Map<String, dynamic> json) {
    return AnalyseIA(
      score: json['score'] ?? 0,
      niveauRisque: json['niveau_risque'] ?? '',
      resume: json['resume'] ?? '',
      conseil: json['conseil'] ?? '',
    );
  }
}
