// import 'package:airq/app/constants/colors.dart';
// import 'package:airq/app/modules/dashboard/components/selection_dragger.dart';
// import 'package:airq/app/modules/dashboard/components/station_item.dart';
// import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
// import 'package:airq/app/widgets/pcard.dart';
// import 'package:airq/controllers/dataset_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class WindowSelector extends GetView<SummaryController> {
//   const WindowSelector({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<SummaryController>(
//       builder: (_) => GetBuilder<DatasetController>(
//         builder: (datasetController) => Scrollbar(
//           isAlwaysShown: true,
//           controller: controller.scrollController,
//           child: PCard(
//             child: Container(
//               width: double.infinity,
//               height: double.infinity,
//               child: Stack(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       top: selectorSpaceTop,
//                       bottom: selectorSpaceBottom,
//                     ),
//                     child: ListView.separated(
//                       controller: controller.scrollController,
//                       shrinkWrap: true,
//                       // physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (_, index) {
//                         return StationItem(
//                           index: index,
//                           station: controller.stations[index],
//                           selected: controller
//                               .isStationSelected(controller.stations[index]),
//                           name: controller.stations[index].name,
//                           intersection: controller.intersectionMatrix,
//                           sections: controller.getMissingMatrix(
//                             controller.stations[index],
//                             monthsMode: datasetController.granularity ==
//                                 Granularity.monthly,
//                           ),
//                           colors: List.generate(
//                             controller.selectedPollutants.length,
//                             (index) =>
//                                 controller.selectedPollutants[index].color,
//                           ),
//                         );
//                       },
//                       separatorBuilder: (c, _) => const SizedBox(
//                         height: 5,
//                       ),
//                       itemCount: controller.stations.length,
//                     ),
//                   ),
//                   Positioned.fill(
//                     child: Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       padding: const EdgeInsets.only(
//                         top: selectorSpaceTop,
//                         bottom: selectorSpaceBottom,
//                       ),
//                       child: const SelectionDragger(),
//                     ),
//                   ),
//                   const Positioned.fill(
//                     child: _SelectorDecoration(),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// const double dateWidth = 50;

// class _SelectorDecoration extends GetView<SummaryController> {
//   const _SelectorDecoration({Key? key}) : super(key: key);

//   DatasetController get datasetController => Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(
//             width: selectorSpaceLeft,
//             child: Text(
//               'Station',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 const SizedBox(height: selectorSpaceTop),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: List.generate(
//                       controller.numberYears + 1,
//                       (index) => VerticalDivider(
//                         width: 3,
//                         color: pColorDark.withOpacity(0.9),
//                         thickness: 3,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: selectorSpaceBottom,
//                   child: Stack(children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: List.generate(
//                         controller.numberYears + 1,
//                         (index) => index == (controller.numberYears)
//                             ? const SizedBox()
//                             : SizedBox(
//                                 width: dateWidth,
//                                 child: Text(
//                                   DateTime(datasetController
//                                               .yearRange.first.year +
//                                           index)
//                                       .toString()
//                                       .substring(0, 4),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     color: pColorDark,
//                                     fontSize: 17,
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: Container(
//                         width: dateWidth,
//                         alignment: Alignment.topRight,
//                         child: Text(
//                           DateTime(datasetController.yearRange.first.year +
//                                   controller.numberYears)
//                               .toString()
//                               .substring(0, 4),
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             color: pColorDark,
//                             fontSize: 17,
//                           ),
//                         ),
//                       ),
//                     )
//                   ]),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: selectorSpaceRight),
//         ],
//       ),
//     );
//   }
// }
