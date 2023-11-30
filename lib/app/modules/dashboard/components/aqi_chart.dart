import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/modules/dashboard/components/aqi_chart_painter.dart';
import 'package:airq_ui/app/modules/dashboard/components/aqi_sections.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/axis.dart';
import 'package:airq_ui/app/widgets/common/pbutton.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/window_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

int MIN_CHART_CLUSTERS = 12;

class AqiChart extends StatefulWidget {
  const AqiChart({super.key});

  @override
  State<AqiChart> createState() => _AqiChartState();
}

class _AqiChartState extends State<AqiChart> {
  DatasetController datasetController = Get.find();

  bool clusterMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text('Show clusters'),
              SizedBox(width: 10),
              Switch(
                value: clusterMode,
                onChanged: (val) {
                  setState(() {
                    clusterMode = val;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: LeftAxis(
              xMaxValue: 0,
              xMinValue: 2,
              yMaxValue: 500,
              yMinValue: 0,
              yAxisLabel: 'IAQI',
              xAxisLabel: 'Pollutant',
              yDivisions: 6,
              xDivisions: datasetController.iaqis!.keys.toList().length,
              xLabels: List.generate(
                  datasetController.iaqis!.keys.toList().length,
                  (index) => (datasetController.pollutants.firstWhere(
                      (element) =>
                          element.id ==
                          datasetController.iaqis!.keys.toList()[index])).name),
              child: AqiSections(
                showIaqi: true,
                minValue: 0,
                maxValue: 500,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  // color: Colors.red,
                  child: GetBuilder<DashboardController>(
                    builder: (_) => AqiChartBars(
                      clusterMode: clusterMode,
                    ),
                    // builder: (_) => CustomPaint(
                    //   painter: AqiChartPainter(),
                    // ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AqiChartBars extends StatefulWidget {
  final bool clusterMode;
  const AqiChartBars({
    required this.clusterMode,
    super.key,
  });

  @override
  State<AqiChartBars> createState() => _AqiChartBarsState();
}

class _AqiChartBarsState extends State<AqiChartBars> {
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();
  List<IPoint> get ipoints => datasetController.filteredPoints;

  int get n_iaqis => datasetController.iaqis!.length;

  List<int> get pollIds => datasetController.iaqis!.keys.toList();

  late double _height;
  late double _width;

  double value2Heigh(double value) {
    return uiRangeConverter(value, 0, 500, 0, _height);
  }

  double calculateMean(List<double> numbers) {
    if (numbers.isEmpty) return 0.0;

    double sum = numbers.reduce((a, b) => a + b);
    return sum / numbers.length;
  }

  double calculateStandardDeviation(List<double> numbers) {
    if (numbers.isEmpty) return 0.0;

    double mean = calculateMean(numbers);
    double variance = 0.0;

    for (var number in numbers) {
      variance += pow(number - mean, 2);
    }

    variance /= numbers.length;

    return sqrt(variance);
  }

  Offset getPointsMeansStds(List<IPoint> points, int pollId) {
    List<double> values = List.generate(
        points.length, (index) => points[index].data.iaqis[pollId]!.toDouble());
    double mean = calculateMean(values);
    double std = calculateStandardDeviation(values);

    return Offset(mean, std);
  }

  Widget _bar(Offset meanStd, Color color) {
    return Container(
      width: 8,
      height: value2Heigh(meanStd.dx) + value2Heigh(meanStd.dy),
      clipBehavior: Clip.none,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: value2Heigh(meanStd.dy),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                color: color,
              ),
              height: value2Heigh(meanStd.dx),
              width: 8,
            ),
          ),
          Positioned(
            top: 0,
            left: 3,
            child: Container(
              width: 2,
              height: value2Heigh(meanStd.dy) * 2,
              color: Colors.black,
            ),
          ),
          Positioned(
            top: value2Heigh(meanStd.dy) * 2,
            left: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                color: pColorLight,
              ),
              height: 2,
              width: 6,
            ),
          ),
          Positioned(
            top: 0,
            left: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                color: pColorLight,
              ),
              height: 2,
              width: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedPollBars() {
    List<IPoint> points = [];
    for (var i = 0; i < ipoints.length; i++) {
      if (ipoints[i].selected) {
        points.add(ipoints[i]);
      }
    }
    List<Offset> meanStds = [];
    for (int i = 0; i < n_iaqis; ++i) {
      Offset meanStd = getPointsMeansStds(points, pollIds[i]);
      meanStds.add(meanStd);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        n_iaqis,
        (index) => _bar(
          meanStds[index],
          pColorPrimary,
        ),
      ),
    );
  }

  Widget clusterPollBars() {
    int nClusters = datasetController.clusterIds.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        n_iaqis,
        (index) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            min(nClusters, MIN_CHART_CLUSTERS),
            (k) => Builder(builder: (context) {
              String clusterId = datasetController.clusterIds[k];
              ClusterData clusterData =
                  datasetController.clustersData[clusterId]!;
              // return Container();
              List<IPoint> points = clusterData.ipoints;
              Offset meanStd = getPointsMeansStds(points, pollIds[index]);
              return _bar(meanStd, clusterData.color);
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _height = constraints.maxHeight;
      _width = constraints.maxWidth;
      return Container(
          width: double.infinity,
          height: double.infinity,
          child: !widget.clusterMode ? selectedPollBars() : clusterPollBars()
          // child: selectedPollBars()
          );
    });
  }
}
