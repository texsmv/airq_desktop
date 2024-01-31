// import 'package:airq_ui/app/modules/dashboard/components/outliers_painter.dart';
// import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
// import 'package:airq_ui/app/modules/subset/controllers/subset_controller.dart';
// import 'package:airq_ui/app/visualizations/multiChart/multi_chart.dart';
// import 'package:airq_ui/app/widgets/axis.dart';
// import 'package:airq_ui/app/widgets/subset/subset_controller.dart';
// import 'package:airq_ui/controllers/dataset_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../iprojection/ipoint.dart';

// class SubsectProjection extends StatefulWidget {
//   const SubsectProjection({super.key});

//   @override
//   State<SubsectProjection> createState() => _SubsectProjectionState();
// }

// class _SubsectProjectionState extends State<SubsectProjection> {
//   SubsetProjectionController controller = Get.put(SubsetProjectionController());
//   DatasetController datasetController = Get.find();
//   DashboardController dashController = Get.find();
//   @override
//   void initState() {
//     controller.onPointsSelected = (List<IPoint> points) {
//       print(points.length);
//     };
//     // controller.onPointPicked = widget.onPointPicked;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Expanded(
//         child: Listener(
//           onPointerDown: controller.onPointerDown,
//           onPointerUp: controller.onPointerUp,
//           onPointerMove: controller.onPointerMove,
//           // onPointerHover: controller.onPointerHover,
//           child: Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: Colors.white,
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: CustomPaint(
//                     painter: OutliersPainter(
//                       saveCanvasCoords: true,
//                       ipoints: controller.points,
//                       borderColors: List.generate(
//                           controller.points.length, (index) => Colors.black),
//                       fillColors: List.generate(
//                           controller.points.length, (index) => Colors.black),
//                       coords: [
//                         controller.ycoords,
//                         controller.xcoords,
//                       ],
//                       radius:
//                           List.generate(controller.points.length, (index) => 5),
//                       maxX: controller.maxX,
//                       maxY: controller.maxY,
//                       minX: controller.minX,
//                       minY: controller.minY,
//                     ),
//                   ),
//                 ),
//                 Obx(
//                   () => Positioned(
//                     left: controller.selectionHorizontalStart,
//                     top: controller.selectionVerticalStart,
//                     child: Visibility(
//                       visible: controller.allowSelection,
//                       child: Container(
//                         color: Colors.blue.withAlpha(120),
//                         width: controller.selectionWidth,
//                         height: controller.selectionHeight,
//                         // width: 100,
//                         // height: 100,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//       Expanded(
//         child: Container(
//             color: Colors.white,
//             height: double.infinity,
//             width: double.infinity,
//             child: LeftAxis(
//               xMaxValue: xMaxValueSeries,
//               xMinValue: 1,
//               yMaxValue: datasetController.maxValue,
//               yMinValue: datasetController.minValue,

//               // controller.ts_visualization ==
//               //         0
//               //     ? controller.yMinValue
//               //     : datasetController
//               //             .minMeansValue ??
//               //         0,
//               yAxisLabel: 'Magnitude',
//               xAxisLabel: 'Time',
//               yDivisions: 5,
//               xDivisions: 12,
//               xLabels: datasetController.granularity != Granularity.annual
//                   ? null
//                   : [
//                       "Jan",
//                       "Feb",
//                       "Mar",
//                       "Apr",
//                       "May",
//                       "Jun",
//                       "Jul",
//                       "Aug",
//                       "Sep",
//                       "Oct",
//                       "Nov",
//                       "Dec"
//                     ],
//               child: MultiChart(
//                 pollutant: dashController.projectedPollutant,
//                 models: controller.points,
//                 minValue: datasetController.minValue,
//                 maxValue: datasetController.maxValue,
//               ),
//             )),
//       ),
//     ]);
//   }

//   double get xMaxValueSeries {
//     if (datasetController.granularity == Granularity.monthly) {
//       return 30;
//     } else if (datasetController.granularity == Granularity.annual) {
//       return 365;
//     } else {
//       return 25;
//     }
//   }
// }
