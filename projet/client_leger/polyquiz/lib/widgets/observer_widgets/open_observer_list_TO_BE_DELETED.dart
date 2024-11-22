import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/observer_widgets/observation_list_widget.dart';

class openObservationListButton extends StatelessWidget {
  const openObservationListButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () {open(context);}, child: Text('Open it'));
  }

  void open(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            Dialog(
              child: Container(
                width: 700,
                height: 700,
                child: ObservationListWidget(),
              ),
            )
    );
  }
}
