import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/theme_service.dart';

class Histogram extends StatefulWidget {
  final Map<String, bool> responseValue;
  final Map<String, num> responseNumber;

  const Histogram({
    super.key,
    required this.responseValue,
    required this.responseNumber,
  });

  @override
  State<Histogram> createState() => _HistogramWidgetState();
}

class _HistogramWidgetState extends State<Histogram> {
  ThemeService _themeService = ThemeService.instance;

  Color getColor(int index) {
    if (widget.responseValue.entries.toList()[index].value) {
      return Color.fromRGBO(123, 229, 117, 1);
    } else {
      return Color.fromRGBO(246, 53, 53, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0,
      width: 650.0,
      margin: EdgeInsets.all(24.0),
      child: BarChart(BarChartData(
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (widget.responseValue.isNotEmpty) {
                  return Text(
                      index < widget.responseValue.length
                          ? widget.responseValue.keys.toList()[index]
                          : '',
                      style: TextStyle(color: _themeService.mainAccent.value));
                } else {
                  return Text('');
                }
              },
            ),
          ),
        ),
        barGroups: widget.responseNumber.entries
            .toList()
            .asMap()
            .map((index, entry) {
              int value = entry.value.toInt();
              return MapEntry(
                  index,
                  BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        color: getColor(index),
                        width: 50,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ));
            })
            .values
            .toList(),
      )),
    );
  }
}
