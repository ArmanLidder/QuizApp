import 'package:polyquiz/classes/timer.dart';

class TimeService {
  static final TimeService _instance = TimeService._internal();

  factory TimeService() {
    return _instance;
  }

  TimeService._internal();

  final List<ClientTimer> _timers = [];
  final int _tick = 1000;

  List<ClientTimer> get timersArray => List.unmodifiable(_timers);

  ClientTimer createTimer(int startValue) {
    final timer = ClientTimer(startValue);
    _timers.add(timer);
    return timer;
  }

  void deleteTimerByIndex(int index) {
    if (index >= 0 && index < _timers.length) {
      _timers.removeAt(index);
    }
  }

  void deleteAllTimers() {
    for (int i = 0; i < _timers.length; i++) {
      stopTimer(i);
    }
    _timers.clear();
  }

  ClientTimer getTimer(int index) {
    return _timers[index];
  }

  int getInitialValue(int index) {
    return _timers[index].initialTime;
  }

  int getTime(int index) {
    return _timers[index].time;
  }

  void setTime(int index, int newTime) {
    _timers[index].setTime(newTime);
  }

  void startTimer(int index) {
    setTime(index, getInitialValue(index));
    if (_timers[index].intervalValue != null) return;
    //todo
  }

  void stopTimer(int index) {
    //todo
  }
}
