import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/modules/dashboard/components/outliers_painter.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OutliersChart extends StatefulWidget {
  OutliersChart({Key? key}) : super(key: key);

  @override
  State<OutliersChart> createState() => _OutliersChartState();
}

class _OutliersChartState extends State<OutliersChart> {
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();
  Map<int, List<dynamic>> coordinates = {};
  Map<int, List<Color>> fillColors = {};
  Map<int, List<Color>> borderColors = {};
  Map<int, List<double>> radius = {};
  Map<int, List<dynamic>> minValues = {};
  Map<int, List<dynamic>> maxValues = {};

  Color nodeColor = const Color.fromRGBO(120, 120, 120, 1);
  Color normalFillColor = const Color.fromRGBO(190, 190, 190, 1);
  Color normalBorderColor = const Color.fromRGBO(170, 170, 170, 1);
  Color selectedBorderColor = Colors.black;

  void createData() {
    for (PollutantModel pollutant in datasetController.pollutants) {
      List<dynamic> coords = datasetController.fdaOutliers[pollutant.id]!;
      List<Color> fColors = [];
      List<Color> bColors = [];
      List<double> radiusList = [];

      Color normalFillPaint = Color.fromRGBO(190, 190, 190, 1);

      for (var i = 0; i < datasetController.globalPoints!.length; i++) {
        IPoint point = datasetController.globalPoints![i];
        late Color fcolor;
        late Color bcolor;
        double pradius = 3;

        if (point.cluster != null) {
          fcolor = uiClusterColor(point.cluster!).withOpacity(0.4);
        } else {
          fcolor = normalFillPaint;
        }
        bcolor = normalBorderColor;
        if (point.selected) {
          bcolor = selectedBorderColor;
        }

        if (point.selected) {
          pradius = 6.0;
        }
        if (point.isHighlighted) {
          pradius = 9.0;
        }

        radiusList.add(pradius);
        fColors.add(fcolor);
        bColors.add(bcolor);
      }
      coordinates[pollutant.id] = coords;
      fillColors[pollutant.id] = fColors;
      borderColors[pollutant.id] = bColors;
      radius[pollutant.id] = radiusList;
      minValues[pollutant.id] = [
        List<double>.from(coords[1]).reduce(min),
        List<double>.from(coords[0]).reduce(min)
      ];
      maxValues[pollutant.id] = [
        List<double>.from(coords[1]).reduce(max),
        List<double>.from(coords[0]).reduce(max)
      ];
    }
  }

  @override
  void didUpdateWidget(OutliersChart oldWidget) {
    createData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    createData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: datasetController.pollutants.length,
      itemBuilder: (context, index) {
        PollutantModel pollutant = datasetController.pollutants[index];
        return GestureDetector(
          onTap: () {
            dashboardController.selectPollutant(pollutant.name);
          },
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                  width: pollutant.id == datasetController.projectedPollutant.id
                      ? 4
                      : 2,
                  color: pollutant.id == datasetController.projectedPollutant.id
                      ? pColorAccent
                      : pColorGray),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                Text(pollutant.name),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CustomPaint(
                      painter: OutliersPainter(
                        ipoints: datasetController.globalPoints!,
                        borderColors: borderColors[pollutant.id]!,
                        fillColors: fillColors[pollutant.id]!,
                        coords: coordinates[pollutant.id]!,
                        radius: radius[pollutant.id]!,
                        maxX: maxValues[pollutant.id]![0],
                        maxY: maxValues[pollutant.id]![1],
                        minX: minValues[pollutant.id]![0],
                        minY: minValues[pollutant.id]![1],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}





// import 'package:airq_ui/app/ui_utils.dart';
// import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
// import 'package:airq_ui/controllers/dataset_controller.dart';
// import 'package:airq_ui/models/pollutant_model.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class OutliersChart extends StatefulWidget {
//   OutliersChart({Key? key}) : super(key: key);

//   @override
//   State<OutliersChart> createState() => _OutliersChartState();
// }

// class _OutliersChartState extends State<OutliersChart> {
//   DatasetController datasetController = Get.find();
//   Map<int, List<ScatterSpot>> scatterpots = {};

//   @override
//   void didUpdateWidget(OutliersChart oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     for (PollutantModel pollutant in datasetController.pollutants) {
//       List<ScatterSpot> spots = [];
//       List<dynamic> coords = datasetController.fdaOutliers[pollutant.id]!;

//       Color normalFillPaint = Color.fromRGBO(190, 190, 190, 1);

//       for (var i = 0; i < datasetController.globalPoints!.length; i++) {
//         IPoint point = datasetController.globalPoints![i];
//         late Color color;

//         if (point.cluster != null) {
//           color = uiClusterColor(point.cluster!).withOpacity(0.4);
//         } else {
//           color = normalFillPaint;
//         }
//         ScatterSpot spot =
//             ScatterSpot(coords[0][i], coords[1][i], color: color);
//         spots.add(spot);
//       }
//       scatterpots[pollutant.id] = spots;
//     }
//   }

//   @override
//   void initState() {
//     for (PollutantModel pollutant in datasetController.pollutants) {
//       List<ScatterSpot> spots = [];
//       List<dynamic> coords = datasetController.fdaOutliers[pollutant.id]!;

//       Color normalFillPaint = Color.fromRGBO(190, 190, 190, 1);

//       for (var i = 0; i < datasetController.globalPoints!.length; i++) {
//         IPoint point = datasetController.globalPoints![i];
//         late Color color;

//         if (point.cluster != null) {
//           color = uiClusterColor(point.cluster!).withOpacity(0.4);
//         } else {
//           color = normalFillPaint;
//         }
//         ScatterSpot spot =
//             ScatterSpot(coords[0][i], coords[1][i], color: color);
//         spots.add(spot);
//       }
//       scatterpots[pollutant.id] = spots;
//     }

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: datasetController.pollutants.length,
//       itemBuilder: (context, index) {
//         PollutantModel pollutant = datasetController.pollutants[index];
//         return SizedBox(
//           height: 140,
//           width: double.infinity,
//           child: ScatterChart(
//             ScatterChartData(
//               scatterLabelSettings: ScatterLabelSettings(
//                 showLabel: false,
//               ),
//               scatterSpots: scatterpots[pollutant.id]!,
//             ),
//             swapAnimationDuration: Duration(milliseconds: 150), // Optional
//             swapAnimationCurve: Curves.linear, // Optional
//           ),
//         );
//       },
//     );
//   }
// }
