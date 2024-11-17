import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String userUid;
  final String message;
  final dynamic createdAt;

  Message({required this.userUid, required this.message, this.createdAt});

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
  final bool isPrivate;
  final List<String> permittedUsers;
  final List<Message> messages;

  Canal({required this.name, required this.isPrivate, required this.permittedUsers, required this.messages, this.id});

  Canal.fromJson(Map<String, dynamic> json)
    : id = json['id'] != null ? json['id'] as String : null,
      name = json['name'] as String,
      isPrivate = json['isPrivate'] as bool,
      permittedUsers = (json['permittedUsers'] as List<dynamic>)
        .map((user) => user as String)
        .toList(),
      messages = (json['messages'] as List<dynamic>)
        .map((message) => Message.fromJson(message))
        .toList();

  factory Canal.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Canal(
      id: doc.id,
      name: data['name'] as String,
      isPrivate: data['isPrivate'] as bool,
      permittedUsers: (data['permittedUsers'] as List<dynamic>)
        .map((user) => user as String)
        .toList(),
      messages: (data['messages'] as List<dynamic>)
        .map((message) => Message.fromJson(message))
        .toList(),
    );
  }

  Map<String, dynamic> toJson() => id != null ? {
    'id': id,
    'name': name,
    'isPrivate': isPrivate,
    'permittedUsers': permittedUsers,
    'messages': messages.map((message) => message.toJson()).toList()
  } : {
    'name': name,
    'isPrivate': isPrivate,
    'permittedUsers': permittedUsers,
    'messages': messages.map((message) => message.toJson()).toList()
  };
}