import 'package:airq_ui/app/modules/dashboard/components/aqi_chart_painter.dart';
import 'package:airq_ui/app/modules/dashboard/components/aqi_sections.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/widgets/axis.dart';
import 'package:airq_ui/app/widgets/common/pbutton.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/window_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AqiChart extends StatefulWidget {
  const AqiChart({super.key});

  @override
  State<AqiChart> createState() => _AqiChartState();
}

class _AqiChartState extends State<AqiChart> {
  DatasetController datasetController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          PButton(
            text: 'Load',
            onTap: () {
              datasetController.loadIaqis();
            },
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
              xDivisions: 3,
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
                    builder: (_) => CustomPaint(
                      painter: AqiChartPainter(),
                    ),
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
