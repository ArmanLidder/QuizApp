class Message {
  final String userUid;
  final String message;
  final dynamic createdAt;

  Message(this.userUid, this.message, {this.createdAt});

  Message.fromJson(Map<String, dynamic> json)
    : userUid = json['userUid'] as String,
      message = json['message'] as String,
      createdAt = json['createdAt'] as dynamic;

  Map<String, dynamic> toJson() => {
    'userUid': userUid,
    'message': message,
    'createdAt': createdAt,
  };
}