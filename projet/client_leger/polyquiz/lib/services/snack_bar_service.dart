import 'package:flutter/material.dart';

class SnackbarService {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  SnackbarService([GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey])
      : _scaffoldMessengerKey = scaffoldMessengerKey ?? GlobalKey<ScaffoldMessengerState>();

  void show(String message, {String actionLabel = 'Fermer', VoidCallback? onAction, SnackBarAction? action, SnackBarBehavior behavior = SnackBarBehavior.fixed, Duration duration = const Duration(seconds: 5)}) {
    final snackBar = SnackBar(
      content: Text(message),
      action: action ?? (onAction != null ? SnackBarAction(label: actionLabel, onPressed: onAction) : null),
      duration: duration,
      behavior: behavior,
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}