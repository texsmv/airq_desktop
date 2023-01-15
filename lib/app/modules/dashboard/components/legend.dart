// import 'package:airq/app/modules/dashboard/controllers/dashboard_controller.dart';
// import 'package:airq/app/modules/dashboard/controllers/summary_controller.dart';
// import 'package:airq/app/widgets/pcard.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';

// class Legend extends GetView<SummaryController> {
//   const Legend({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return PCard(
//       child: SizedBox(
//         height: 50,
//         width: double.infinity,
//         child: ListView.separated(
//           shrinkWrap: true,
//           separatorBuilder: (context, index) => const SizedBox(width: 20),
//           scrollDirection: Axis.horizontal,
//           itemCount: controller.pollutants.length,
//           itemBuilder: (context, index) {
//             String variable = controller.pollutants[index].name;
//             Color color = controller.pollutants[index].color;
//             return SizedBox(
//               height: 40,
//               width: 80,
//               child: Row(
//                 children: [
//                   Text(variable + ":"),
//                   const SizedBox(width: 10),
//                   Container(
//                     width: 20,
//                     height: 20,
//                     color: color,
//                   )
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
