import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Histogram extends StatefulWidget {
  const Histogram({super.key});

  @override
  State<Histogram> createState() => _HistogramWidgetState();
}

class _HistogramWidgetState extends State<Histogram> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.0,
      width: 500.0,
      margin: EdgeInsets.all(24.0),
      child: BarChart(BarChartData(barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5)])
      ])),
    );
  }
}
