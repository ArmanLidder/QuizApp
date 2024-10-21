
class Player {
  final String id;
  final String name;

  Player({required this.id, required this.name});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['_id'],
      name: json['name'],
    );
  }
}

const double BONUS_MULTIPLIER = 1.2;
const int TESTING_TRANSITION_TIMER = 3;
const int QRL_DURATION = 60;