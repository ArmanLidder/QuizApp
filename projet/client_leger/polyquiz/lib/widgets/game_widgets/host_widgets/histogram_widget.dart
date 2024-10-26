import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';

class Histogram extends StatefulWidget {
  const Histogram({super.key});

  @override
  State<Histogram> createState() => _HistogramWidgetState();
}

class _HistogramWidgetState extends State<Histogram> {
  HostInterfaceManagementService _hostInterfaceManagementService =
      HostInterfaceManagementService();
  List<String> choices = ['choice1', 'choice2', 'choice3', 'choice4'];
  List<double> answers = [3, 1, 2, 1];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0,
      width: 650.0,
      margin: EdgeInsets.all(24.0),
      child: AnimatedBuilder(
        animation: _hostInterfaceManagementService,
        builder: (BuildContext context, Widget? snapshot) {
          return BarChart(BarChartData(
            titlesData: FlTitlesData(
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (_hostInterfaceManagementService
                        .histogramDataValue.isNotEmpty) {
                      return Text(index <
                              _hostInterfaceManagementService
                                  .histogramDataValue.length
                          ? _hostInterfaceManagementService
                              .histogramDataValue.keys
                              .toList()[index]
                          : '');
                    } else {
                      return Text('');
                    }
                    ;
                  },
                ),
              ),
            ),
            barGroups: answers.asMap().entries.map((entry) {
              int index = entry.key;
              double value = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                      toY: value,
                      color: Color.fromRGBO(246, 53, 53, 1),
                      width: 50,
                      borderRadius: BorderRadius.zero),
                ],
              );
            }).toList(),
          ));
        },
      ),
    );
  }
}
