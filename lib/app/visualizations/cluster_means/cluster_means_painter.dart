import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ClusterMeansPainter extends CustomPainter {
  Map<String, List<double>> means;
  Map<String, List<double>> stds;
  double minV;
  double maxV;

  ClusterMeansPainter({
    required this.means,
    required this.stds,
    required this.minV,
    required this.maxV,
  });
  late int _n;
  late double _width;
  late double _height;
  late double _horizontalSpace;
  late Canvas _canvas;
  int get timeLen =>
      datasetController.globalPoints![0].data.values.values.first.length;
  // double get minV {
  //   List<double> allMeans = [];
  //   for (var clusterId in datasetController.clusterIds) {
  //     allMeans.addAll(means[clusterId]!);
  //   }
  //   datasetController.minMeansValue = allMeans.reduce(min);
  //   Future.delayed(Duration(milliseconds: 200)).then((value) => () {
  //         // datasetController.update();
  //         dashboardController.update();
  //       });
  //   return datasetController.minMeansValue!;
  // }

  // double get maxV {
  //   List<double> allMeans = [];
  //   for (var clusterId in datasetController.clusterIds) {
  //     allMeans.addAll(means[clusterId]!);
  //   }
  //   datasetController.maxMeansValue = allMeans.reduce(max);
  //   Future.delayed(Duration(milliseconds: 200)).then((value) => () {
  //         // datasetController.update();
  //         dashboardController.update();
  //       });
  //   return datasetController.maxMeansValue!;
  // }

  double get nStds => 1;
  DatasetController get datasetController => Get.find();
  DashboardController get dashboardController => Get.find();

  @override
  void paint(Canvas canvas, Size size) {
    _n = timeLen;
    _width = size.width;
    _height = size.height;
    _horizontalSpace = _width / (_n - 1);
    _canvas = canvas;

    for (var clusterId in datasetController.clusterIds) {
      drawMean(clusterId);
      drawStd(clusterId);
    }
  }

  void drawMean(String clusterId) {
    Path path = Path();
    path.moveTo(0, value2Heigh(means[clusterId]![0]));
    for (var i = 1; i < _n; i++) {
      path.lineTo(
        i * _horizontalSpace,
        value2Heigh(means[clusterId]![i]),
      );
    }
    Paint paint = Paint()
      ..color = datasetController.clusterColors[clusterId]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    _canvas.drawPath(
      path,
      paint,
    );
  }

  void drawStd(String clusterId) {
    Path path = Path();
    path.moveTo(
        0, value2Heigh(means[clusterId]![0] + stds[clusterId]![0] * nStds / 2));
    for (var i = 1; i < _n; i++) {
      path.lineTo(
        i * _horizontalSpace,
        value2Heigh(means[clusterId]![i] + stds[clusterId]![i] * nStds / 2),
      );
    }

    path.lineTo(
        _width,
        value2Heigh(
            means[clusterId]![_n - 1] - stds[clusterId]![_n - 1] * nStds / 2));

    for (var i = _n - 1; i > -1; i--) {
      path.lineTo(
        i * _horizontalSpace,
        value2Heigh(means[clusterId]![i] - stds[clusterId]![i] * nStds / 2),
        // value2Heigh(means[clusterId]![i] - 100),
      );
    }
    path.lineTo(
        0, value2Heigh(means[clusterId]![0] + stds[clusterId]![0] * nStds / 2));

    Paint paint = Paint()
      ..color = datasetController.clusterColors[clusterId]!.withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..strokeWidth = 14;
    _canvas.drawPath(
      path,
      paint,
    );
  }

  double value2Heigh(double value) {
    return _height - uiRangeConverter(value, minV, maxV, 0, _height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
