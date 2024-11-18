import 'package:flutter/material.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/qrl_evaluation_service.dart';

class HostGrading extends StatefulWidget {
  final List<QuestionStatistics> gameStats;
  final Map<String, ResponseData> qrlAnswers;
  HostGrading({
    Key? key,
    required this.gameStats,
    required this.qrlAnswers,
  }) : super(key: key);

  @override
  State<HostGrading> createState() => _HostGradingState();
}

class _HostGradingState extends State<HostGrading> {
  QrlEvaluationService _qrlEvaluationService = QrlEvaluationService();

  @override
  void initState() {
    super.initState();
    this._qrlEvaluationService.initialize(widget.qrlAnswers);
  }

  @override
  void dispose() {
    this._qrlEvaluationService.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
          animation: _qrlEvaluationService,
          builder: (BuildContext context, Widget? snapshot) {
            if (!_qrlEvaluationService.isCorrectionFinished) {
              return Column(
                children: [
                  Divider(),
                  Text('Correction de la réponse:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Text('Joueur: ${_qrlEvaluationService.currentUsername}',
                  //     style: TextStyle(fontSize: 16)),
                  Text('Réponse: ${_qrlEvaluationService.currentAnswer}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownMenu(
                        dropdownMenuEntries: <DropdownMenuEntry<int>>[
                          DropdownMenuEntry(
                              value: _qrlEvaluationService.scores[0],
                              label: '0'),
                          DropdownMenuEntry(
                              value: _qrlEvaluationService.scores[1],
                              label: '50'),
                          DropdownMenuEntry(
                              value: _qrlEvaluationService.scores[2],
                              label: '100')
                        ],
                        onSelected: (value) {
                          if (value != null)
                            _qrlEvaluationService.inputPoint = value;
                        },
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  Color.fromRGBO(53, 121, 246, 1))),
                          onPressed: () {
                            if (_qrlEvaluationService.inputPoint != -1)
                              _qrlEvaluationService
                                  .submitPoint(widget.gameStats);
                          },
                          child: Text(
                            'Confirmer',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          )),
                    ],
                  ),
                  Divider()
                ],
              );
            } else {
              return 
              Container();
              // Column(
              //   children: [
              //     DataTable(
              //         headingRowColor: WidgetStateProperty.all(
              //             Color.fromRGBO(53, 121, 246, 1)),
              //         headingTextStyle: TextStyle(
              //             color: Color.fromRGBO(255, 255, 255, 1),
              //             fontWeight: FontWeight.bold),
              //         border: TableBorder.all(),
              //         columns: [
              //           DataColumn(
              //             label: Expanded(child: Center(child: Text('Nom'))),
              //           ),
              //           DataColumn(
              //             label: Expanded(child: Center(child: Text('Note'))),
              //           ),
              //         ],
              //         rows: List<DataRow>.generate(
              //             _qrlEvaluationService.points.length, (index) {
              //           return DataRow(cells: [
              //             DataCell(
              //                 Text(_qrlEvaluationService.usernames[index])),
              //             DataCell(Text(
              //                 _qrlEvaluationService.points[index].toString()))
              //           ]);
              //         })),
              //     SizedBox(height: .0),
              //   ],
              // );
            }
          }),
    );
  }
}
