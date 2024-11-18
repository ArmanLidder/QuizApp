import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class RoomValidationService with ChangeNotifier {
  final SocketService socketService;

  BehaviorSubject<User?> _userSubject = BehaviorSubject<User?>();
  Stream<User?> get user$ => _userSubject.stream;

  bool isActive = true;
  bool isLocked = false;
  bool isRoomIdValid = false;
  String? roomId = '';
  String? username;
  bool isUsernameValid = false;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;

  RoomValidationService({required this.socketService}) {
    this.loggedInUserService.reloadUser();
    this.userData = this.loggedInUserService.getUser();
  }

  void reloadUserData(){
    this.loggedInUserService.reloadUser();
    this.userData = this.loggedInUserService.getUser();
  }

  void resetService() {
    isActive = true;
    isLocked = false;
    isRoomIdValid = false;
    roomId = '';
    username = '';
    isUsernameValid = false;
    notifyListeners();
  }

  // Future<String> verifyRoomId() async {
  //   return isOnlyDigit() ? await sendRoomId() : 'VALIDATION_CODE_ERROR';
  // }

  Future<User> getCurrentUser() async {
    return (await this.userData) as User;
  }

  Future<String> verifyUsername() async {
    return await sendUsername();
  }

  // Future<String> sendJoinRoomRequest() async {
  //   final user = await getCurrentUser();
  //   return await Future<String>((resolve) {
  //     final usernameData = {'roomId': int.parse(roomId!), 'username': this.userData.uid};
  //     socketService.sendMessageWithAck(SocketEvent.JOIN_GAME, usernameData, (isLocked) {
  //       resolve(handleJoiningRoomValidation(isLocked));
  //     });
  //   });
  // }

  Future<String> sendUsername() async {
    final completer = Completer<String>();
    final user = await getCurrentUser();
    final usernameData = {'roomId': int.parse(roomId!), 'username': user.uid};
    socketService.sendMessageWithAck(
        SocketEvent.VALIDATE_USERNAME, usernameData, (data) {
      if (data != null) {
        completer.complete(handleUsernameValidation(data));
      } else {
        print('Failed to validate username');
        completer.completeError('Failed to validate username');
      }
    });
    return completer.future;
  }

  Future<Map<String, dynamic>> sendRoomId() async {
    final completer = Completer<Map<String, dynamic>>();
    socketService.sendMessageWithAck(SocketEvent.VALIDATE_ROOM_ID, int.parse(roomId!), (data) {
      print('I am here 2303');
      if (data != null) {
        print('I am here 030409');
        completer.complete(data);
        print(data);
      } else {
        print('Failed to validate roomID');
        completer.completeError('Failed to validate roomID');
      }
    });
    return completer.future;
  }

  String handleJoiningRoomValidation(bool isLocked) {
    this.isLocked = isLocked;
    return isLocked ? handleErrors('ROOM_LOCKED') : '';
  }

  String handleUsernameValidation(dynamic data) {
    isUsernameValid = data['isValid'];
    return data['isValid'] ? '' : data['error'];
  }

  String handleRoomIdValidation(dynamic data) {
    String error = '';
    if (!data['isRoom'])
      error = handleErrors('Le code ne correspond a aucune partie en cours. Veuillez réessayer');
    else if (data['isLocked'])
      error = handleErrors('"La partie est vérouillée. Veuillez réessayer."');
    else
      isRoomIdValid = true;
    return error;
  }

  String handleErrors(String errorType) {
    isRoomIdValid = false;
    isUsernameValid = false;
    return errorType;
  }

  bool isOnlyDigit() {
    return roomId?.contains(RegExp(r'^[0-9]{4}$')) ?? false;
  }
}
