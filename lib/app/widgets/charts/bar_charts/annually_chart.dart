// import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AnnuallyChart extends StatefulWidget {
//   // final Map<String, IPoint> selectedPoints;
//   AnnuallyChart({
//     Key? key,
//     // required this.selectedPoints,
//   }) : super(key: key);

//   @override
//   _AnnuallyChartState createState() => _AnnuallyChartState();
// }

// class _AnnuallyChartState extends State<AnnuallyChart> {
//   DatasetController controller = Get.find();
//   // DashboardController dashController = Get.find();

//   List<String> get ids => List.generate(dashController.selectedPoints.length,
//       (index) => dashController.selectedPoints[index].data.id.toString());
//   List<IPoint> get selectedPoints => dashController.selectedPoints;
//   List<double> get annuallyMeans =>
//       dashController.yearMeans[controller.projectedPollutant.id]!;
//   List<int> get annuallyCounts => dashController.yearCounts;

//   @override
//   void initState() {
//     // annuallyMeans = List.generate(
//     //     dashController.yearCounts.length,
//     //     (index) => 0.0);
//     // annuallyCounts = List.generate(
//     //     controller.yearRange.item2 - controller.yearRange.item1, (index) => 0);
//     // computeWeekStats();
//     super.initState();
//   }

//   @override
//   void didUpdateWidget(covariant AnnuallyChart oldWidget) {
//     // computeWeekStats();
//     super.didUpdateWidget(oldWidget);
//   }

//   // void computeWeekStats() {
//   //   annuallyMeans = List.generate(
//   //       controller.yearRange.item2 - controller.yearRange.item1,
//   //       (index) => 0.0);
//   //   annuallyCounts = List.generate(
//   //       controller.yearRange.item2 - controller.yearRange.item1, (index) => 0);
//   //   if (selectedPoints.isEmpty) return;
//   //   for (var i = 0; i < ids.length; i++) {
//   //     // print("-");
//   //     // print(i);
//   //     WeekModel model = selectedPoints[ids[i]];
//   //     // print(model.serie);
//   //     List<DateTime> serieDates = List.generate(
//   //         7, (index) => model.startDate.add(Duration(days: index)));
//   //     for (var k = 0; k < 7; k++) {
//   //       annuallyMeans[serieDates[k].year - controller.yearRange.item1] +=
//   //           model.serie[k];
//   //       annuallyCounts[serieDates[k].year - controller.yearRange.item1] += 1;
//   //     }
//   //   }
//   //   for (var k = 0; k < annuallyMeans.length; k++) {
//   //     if (annuallyCounts[k] != 0) {
//   //       annuallyMeans[k] /= annuallyCounts[k].toDouble();
//   //       annuallyMeans[k] = annuallyMeans[k] * 100;
//   //     }
//   //   }
//   //   // print("annually means");
//   //   // print(annuallyMeans);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // print(weekMeans);
//     return AspectRatio(
//       aspectRatio: 16 / 9,
//       child: Container(
//         child: Chart(
//           state: ChartState.bar(
//             ChartData.fromList(
//               annuallyMeans.map((e) => BarValue<void>(e)).toList(),
//             ),
//             backgroundDecorations: [
//               GridDecoration(
//                 showVerticalGrid: false,
//                 gridColor: Theme.of(context).dividerColor,
//                 showHorizontalValues: true,
//                 showVerticalValues: true,
//                 horizontalAxisStep: 5,
//                 horizontalAxisValueFromValue: (value) =>
//                     (value / 100.0).toStringAsFixed(2),
//                 verticalAxisValueFromIndex: (index) =>
//                     (index + annuallyCounts.length).toString(),
//                 textStyle: TextStyle(
//                   fontSize: 13,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
