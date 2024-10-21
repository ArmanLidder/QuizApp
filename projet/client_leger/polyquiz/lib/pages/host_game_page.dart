import 'package:flutter/material.dart';
import '../services/host_game_service.dart';

class HostInterfaceScreen extends StatefulWidget {
  final String quizId;

  HostInterfaceScreen({required this.quizId,required socketService});

  @override
  _HostInterfaceScreenState createState() => _HostInterfaceScreenState();
}

class _HostInterfaceScreenState extends State<HostInterfaceScreen> {
  final HostInterfaceManagementService _hostService = HostInterfaceManagementService(
    gameService: GameService(),
    socketService: SocketService(),
    interactiveListService: InteractiveListService(),
  );

  @override
  void initState() {
    super.initState();
    _hostService.configureBaseSocketFeatures();
    _hostService.reset();
  }

  bool isDisabled() {
    // Logic to check if button should be disabled.
    return _hostService.isHostEvaluating || _hostService.isPaused;
  }

  void handleHostCommand() {
    if (_hostService.isGameOver) {
      _hostService.handleLastQuestion();
    } else {
      _hostService.requestNextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Host Interface')),
      body: Column(
        children: [
          Text(_hostService.timerText),
          ElevatedButton(
            onPressed: isDisabled() ? null : handleHostCommand,
            child: Text('Next Question'),
          ),
          if (_hostService.isGameOver)
            ElevatedButton(
              onPressed: () => _hostService.handleLastQuestion(),
              child: Text('Show Results'),
            ),
        ],
      ),
    );
  }
}
