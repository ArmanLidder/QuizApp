import 'dart:ffi';

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

class Canal {
  final String? id;
  final String name;
  final Bool isPrivate;
  final List<String> permittedUsers;
  final List<Message> messages;

  Canal(this.name, this.isPrivate, this.permittedUsers, this.messages, {this.id});

  Canal.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? json['id'] as String : null,
      name = json['name'] as String,
      isPrivate = json['isPrivate'] as Bool,
      permittedUsers = (json['permittedUsers'] as List<dynamic>)
        .map((user) => user as String)
        .toList(),
      messages = (json['messages'] as List<dynamic>)
        .map((message) => Message.fromJson(message))
        .toList();

  Map<String, dynamic> toJson() => {
    'id': id != null ? id : null,
    'name': name,
    'isPrivate': isPrivate,
    'permittedUsers': permittedUsers,
    'messages': messages.map((message) => message.toJson()).toList()
  };
}