import 'package:airq_ui/app/visualizations/multiChart/multi_chart_painter.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:flutter/material.dart';

class MultiChart extends StatelessWidget {
  final List<IPoint> models;
  final double minValue;
  final double maxValue;
  const MultiChart({
    Key? key,
    required this.models,
    required this.minValue,
    required this.maxValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return models.isNotEmpty
        ? CustomPaint(
            painter: MultiChartPainter(
              models: models,
              minValue: minValue,
              maxValue: maxValue,
            ),
          )
        : SizedBox();
  }
}
