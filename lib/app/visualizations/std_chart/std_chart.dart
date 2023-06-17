import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/visualizations/multiChart/multi_chart_painter.dart';
import 'package:airq_ui/app/visualizations/std_chart/std_chart_painter.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StdChart extends StatefulWidget {
  final List<IPoint> ipoints;
  final double minValue;
  final double maxValue;
  const StdChart({
    Key? key,
    required this.ipoints,
    required this.minValue,
    required this.maxValue,
  }) : super(key: key);

  @override
  State<StdChart> createState() => _StdChartState();
}

class _StdChartState extends State<StdChart> {
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();

  int get timeLen => widget.ipoints[0].data.values.values.first.length;
  late List<double> means;
  late List<double> stds;
  bool get showShape => dashboardController.showShape;
  PollutantModel get pollutant => datasetController.projectedPollutant;
  List<dynamic> get allValues {
    _allValues = null;
    _allValues ??= List<dynamic>.generate(widget.ipoints.length,
        (index) => widget.ipoints[index].data.values[pollutant.id]!);
    return _allValues!;
  }

  List<dynamic>? _allValues;
  late int n;

  @override
  void initState() {
    computeMeanStd();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StdChart oldWidget) {
    computeMeanStd();
    super.didUpdateWidget(oldWidget);
  }

  void computeMeanStd() {
    means = List.generate(timeLen, (index) => 0);
    stds = List.generate(timeLen, (index) => 0);
    n = 0;

    for (var i = 0; i < widget.ipoints.length; i++) {
      if (widget.ipoints[i].selected) {
        n++;
        for (var j = 0; j < timeLen; j++) {
          means[j] += allValues[i][j];
        }
      }
    }
    for (var j = 0; j < timeLen; j++) {
      means[j] = means[j] / n;
    }

    for (var i = 0; i < widget.ipoints.length; i++) {
      if (widget.ipoints[i].selected) {
        for (var j = 0; j < timeLen; j++) {
          stds[j] += pow(allValues[i][j] - means[j], 2);
        }
      }
    }
    for (var j = 0; j < timeLen; j++) {
      stds[j] = sqrt(stds[j] / n);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(means);
    // print(stds);
    return widget.ipoints.isNotEmpty
        ? CustomPaint(
            painter: StdChartPainter(
              means: means,
              stds: stds,
              minV: showShape ? std_min : widget.minValue,
              maxV: showShape ? std_max : widget.maxValue,
            ),
          )
        : SizedBox();
  }
}
