class JoinTeamData {
  final int roomId;
  final int newTeamId;

  JoinTeamData({required this.roomId, required this.newTeamId});

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'newTeamId': newTeamId,
    };
  }
}
