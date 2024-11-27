import 'package:flutter/material.dart';
import 'package:polyquiz/services/observer_counter_service.dart';

class ObserverCounter extends StatefulWidget {
  @override
  _ObserverCounterState createState() => _ObserverCounterState();
}

class _ObserverCounterState extends State<ObserverCounter> {
  ObserverCounterService observerCounterService = ObserverCounterService();

  @override
  void initState() {
    observerCounterService.initialize();
    print('ObserverCounter initialized ${observerCounterService.obsCount}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_red_eye,
            color: Colors.white.withOpacity(0.8),
            size: 16.0,
          ),
          SizedBox(width: 6.0),
          AnimatedBuilder(
            animation: observerCounterService,
            builder: (context, child) {
              return Text(
                observerCounterService.obsCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
