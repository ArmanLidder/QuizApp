class ClientTimer {
  int? _interval;
  int _counter = 0;
  final int _startValue;

  ClientTimer(this._startValue) {
    _counter = _startValue;
  }

  int get initialTime => _startValue;

  int get time => _counter;

  int? get intervalValue => _interval;

  void setTime(int newTime) {
    _counter = newTime;
  }

  void setIntervalValue(int? interval) {
    _interval = interval;
  }
}
