import 'package:flutter/material.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/qrl_evaluation_service.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/services/theme_service.dart';

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
  GameConfigService gameConfigs = GameConfigService();
  HostInterfaceManagementService hostInterfaceManagementService =
      HostInterfaceManagementService();
  ThemeService _themeService = ThemeService.instance;
  bool revokeAIcorrection = false;

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

  String get AIcorrectionText {
    print(hostInterfaceManagementService.correctedQrlByOpenAi);
    return hostInterfaceManagementService
            .correctedQrlByOpenAi[_qrlEvaluationService.currentUsername]?[1] ??
        "Open AI is down";
  }

  int get AIscore {
    final score = hostInterfaceManagementService
            .correctedQrlByOpenAi[_qrlEvaluationService.currentUsername]?[0] ??
        0;
    print('Score: $score');
    if (!revokeAIcorrection) _qrlEvaluationService.inputPoint = score;
    return score;
  }

  void switchScore(int score) {
    setState(() {
      revokeAIcorrection = true;
      _qrlEvaluationService.inputPoint = score;
    });
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
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _themeService.mainAccent.value)),
                  // Text('Joueur: ${_qrlEvaluationService.currentUsername}',
                  //     style: TextStyle(fontSize: 16)),
                  if (hostInterfaceManagementService
                      .gameService.realGameService.isAION) ...[
                    Text(
                      'Correction IA',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _themeService.mainAccent.value),
                    ),
                    Row(
                      children: [
                        Icon(Icons.smart_toy, color: _themeService.mainAccent.value),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(AIcorrectionText,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  color: _themeService.mainAccent.value)),
                        ),
                      ],
                    ),
                    Text('Points : $AIscore',
                        style:
                            TextStyle(color: _themeService.mainAccent.value)),
                  ],
                  Text('Réponse: ${_qrlEvaluationService.currentAnswer}',
                      style: TextStyle(
                          fontSize: 16, color: _themeService.mainAccent.value)),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        DropdownButton<int>(
                          dropdownColor: _themeService.mainBackground.value,
                        value: revokeAIcorrection ? _qrlEvaluationService.inputPoint : AIscore,
                        style: TextStyle(color: _themeService.mainAccent.value),
                        items: _qrlEvaluationService.scores.map((int score) {
                          return DropdownMenuItem<int>(
                          value: score,
                          child: Text(score.toString(), style: TextStyle(color: _themeService.mainAccent.value),),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                          switchScore(value);
                          }
                        },
                        ),
                      SizedBox(
                        width: 20.0,
                      ),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  _themeService.secondaryBackground.value)),
                          onPressed: () {
                            if (_qrlEvaluationService.inputPoint != -1)
                              _qrlEvaluationService
                                  .submitPoint(widget.gameStats);
                            this.revokeAIcorrection = false;
                            print('I am here multiple times');
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
                return Column(
                  children: [
                    DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            _themeService.secondaryBackground.value),
                        headingTextStyle: TextStyle(
                            color: _themeService.secondaryAccent.value,
                            fontWeight: FontWeight.bold),
                        border: TableBorder.all(),
                        columns: [
                          DataColumn(
                            label: Expanded(child: Center(child: Text('Nom'))),
                          ),
                          DataColumn(
                            label: Expanded(child: Center(child: Text('Note'))),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                            _qrlEvaluationService.points.length, (index) {
                          return DataRow(cells: [
                            DataCell(
                                Text(_qrlEvaluationService.usernames[index])),
                            DataCell(Text(
                                _qrlEvaluationService.points[index].toString()))
                          ]);
                        })),
                    SizedBox(height: .0),
                  ],
                );
            }
          }),
    );
  }
}
