class Score {
  final int points;
  final int bonusCount;
  final bool isBonus;

  Score({
    required this.points,
    required this.bonusCount,
    required this.isBonus,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      points: json['points'] as int,
      bonusCount: json['bonusCount'] as int,
      isBonus: json['isBonus'] as bool,
    );
  }
}
