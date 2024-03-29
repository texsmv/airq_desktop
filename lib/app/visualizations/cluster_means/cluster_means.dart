import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/visualizations/cluster_means/cluster_means_painter.dart';
import 'package:airq_ui/app/visualizations/multiChart/multi_chart_painter.dart';
import 'package:airq_ui/app/visualizations/std_chart/std_chart_painter.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClusterMeans extends StatefulWidget {
  const ClusterMeans({
    Key? key,
  }) : super(key: key);

  @override
  State<ClusterMeans> createState() => _ClusterMeansState();
}

class _ClusterMeansState extends State<ClusterMeans> {
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();

  int get timeLen =>
      datasetController.globalPoints![0].data.values.values.first.length;
  late Map<String, List<double>> means;
  late Map<String, List<double>> stds;
  Map<String, List<IPoint>> get clusters => datasetController.clusters;

  PollutantModel get pollutant => datasetController.projectedPollutant;
  Map<String, List<dynamic>> get allValues {
    if (_allValues == null) {
      _allValues = {};
      for (var clusterId in datasetController.clusterIds) {
        _allValues![clusterId] = List<dynamic>.generate(
            clusters[clusterId]!.length,
            (index) => clusters[clusterId]![index].data.values[pollutant.id]!);
      }
    }
    return _allValues!;
  }

  Map<String, List<dynamic>>? _allValues;
  late int n;

  @override
  void initState() {
    computeMeanStd();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ClusterMeans oldWidget) {
    _allValues = null;
    computeMeanStd();
    super.didUpdateWidget(oldWidget);
  }

  void computeMeanStd() {
    means = {};
    stds = {};
    for (var clusterId in datasetController.clusterIds) {
      List<double> meansl = List.generate(timeLen, (index) => 0);
      List<double> stdsl = List.generate(timeLen, (index) => 0);

      n = 0;
      for (var i = 0; i < clusters[clusterId]!.length; i++) {
        n++;
        for (var j = 0; j < timeLen; j++) {
          meansl[j] += allValues[clusterId]![i][j];
        }
      }
      for (var j = 0; j < timeLen; j++) {
        meansl[j] = meansl[j] / n;
      }

      // for (var i = 0; i < clusters[clusterId]!.length; i++) {
      //   for (var j = 0; j < timeLen; j++) {
      //     stdsl[j] += pow(allValues[clusterId]![i][j] - meansl[j], 2);
      //   }
      // }
      // for (var j = 0; j < timeLen; j++) {
      //   stdsl[j] = sqrt(stdsl[j] / n);
      // }
      means[clusterId] = meansl;
      stds[clusterId] = stdsl;
      print(meansl);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(means);
    // print(stds);
    return datasetController.clusterIds.isNotEmpty
        ? CustomPaint(
            painter: ClusterMeansPainter(
              means: means,
              stds: stds,
            ),
          )
        : SizedBox();
  }
}
