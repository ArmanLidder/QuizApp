import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/theme_service.dart';

class PlayerQrl extends StatefulWidget {
  const PlayerQrl({super.key});

  @override
  State<PlayerQrl> createState() => _PlayerQrlWidgetState();
}

class _PlayerQrlWidgetState extends State<PlayerQrl> {
  int counter = 0;
  var inputText = '';
  String croppedInputText = '';
  GameInterfaceManagementService _gameInterfaceManagementService =
      GameInterfaceManagementService();
  SocketService _socketService = SocketService();
  ThemeService _themeService = ThemeService.instance;
  final TextEditingController _controller = TextEditingController();

  void sendActiveNotice() {
    this._gameInterfaceManagementService.gameService.isActive = true;
    if (this._socketService.isSocketAlive()) {
      this._socketService.sendMessage(SocketEvent.SEND_ACTIVITY_STATUS, {
        'roomId': this
            ._gameInterfaceManagementService
            .gameService
            .realGameService
            .roomId,
        'isActive': true
      });
    }
  }

  void sendInteractionNotice() {
    this._gameInterfaceManagementService.gameService.hasInteracted = true;
    if (this._socketService.isSocketAlive()) {
      this._socketService.sendMessage(
          SocketEvent.NEW_RESPONSE_INTERACTION,
          this
              ._gameInterfaceManagementService
              .gameService
              .realGameService
              .roomId);
    }
  }

  void handleActiveUser() {
    if (!_gameInterfaceManagementService.gameService.isActive) {
      sendActiveNotice();
    }
    if (!_gameInterfaceManagementService.gameService.hasInteracted) {
      sendInteractionNotice();
    }
  }

  @override
  void dispose() {
    this._gameInterfaceManagementService.gameService.isActive = false;
    this._gameInterfaceManagementService.gameService.hasInteracted = false;
    super.dispose();
  }

  Widget getObserverTextFieldQrl() {
    _controller.text = _gameInterfaceManagementService.gameService.qrlAnswer;
    return AnimatedBuilder(
      animation: _gameInterfaceManagementService.gameService,
      builder: (context, snapshot) {
        return TextField(
          style: TextStyle(color: _themeService.mainAccent.value),
          controller: _controller,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: _themeService.mainAccent.value)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: _themeService.mainAccent.value)),
          ),
          expands: true,
          maxLines: null,
          readOnly: true,
          maxLength: 200,
          onChanged: (value) {},
        );
      }
    );
  }

  Widget getRegularTextfield() {
    return TextField(
      style: TextStyle(color: _themeService.mainAccent.value),
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide:
              BorderSide(color: _themeService.mainAccent.value)),
          focusedBorder: OutlineInputBorder(
              borderSide:
              BorderSide(color: _themeService.mainAccent.value)),
          counterText: '${inputText}/200',
          counterStyle: TextStyle(color: _themeService.mainAccent.value),
      ),
      expands: true,
      maxLines: null,
      maxLength: 200,
      onChanged: (value) {
        setState(() {
          croppedInputText = value.trim();
          inputText = (200 - value.characters.length).toString();
          this._gameInterfaceManagementService!.gameService.qrlAnswer =
              croppedInputText;
          this.handleActiveUser();
        });
      },
    );
  }

  Widget getTextField() {
    if (this._gameInterfaceManagementService.gameService.isObserverMode)
      return getObserverTextFieldQrl();
    else
      return getRegularTextfield();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 100.0, 5.0, 5.0),
        child: SizedBox(
          height: 150,
          child: AnimatedBuilder(
            animation: this._gameInterfaceManagementService.gameService,
            builder: (context, snapshot) {
              return getTextField();
            }
          ),
        ),
      ),
    );
  }
}
