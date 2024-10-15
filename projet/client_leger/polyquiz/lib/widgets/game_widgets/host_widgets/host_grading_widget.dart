import 'package:flutter/material.dart';

class HostGrading extends StatefulWidget {
  final String playerName;
  final String playerAnswer;
  const HostGrading(
      {super.key, required this.playerName, required this.playerAnswer});

  @override
  State<HostGrading> createState() => _HostGradingState();
}

class _HostGradingState extends State<HostGrading> {
  List<int> grades = [0, 50, 100];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Divider(),
          Text('Grading of question:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Player: ${widget.playerName}', style: TextStyle(fontSize: 16)),
          Text('Answer: ${widget.playerAnswer}',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 20.0),
          DropdownMenu(dropdownMenuEntries: <DropdownMenuEntry<int>>[
            DropdownMenuEntry(value: grades[0], label: '0'),
            DropdownMenuEntry(value: grades[1], label: '50'),
            DropdownMenuEntry(value: grades[2], label: '100')
          ]),
          SizedBox(height: 20.0),
          TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Color.fromRGBO(53, 121, 246, 1))),
              onPressed: () {},
              child: Text(
                'Confirm',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              )),
          Divider()
        ],
      ),
    );
  }
}
