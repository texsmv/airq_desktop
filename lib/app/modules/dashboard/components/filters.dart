// import 'dart:math';

// import 'package:airq_ui/app/widgets/pcard.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SelectionsFilters extends StatelessWidget {
//   const SelectionsFilters({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return PCard(
//       child: SizedBox(
//         height: 50,
//         child: GetBuilder<SummaryController>(
//           builder: (_) => Row(
//             children: [
//               _SelectionItem(
//                 text: 'by name',
//                 type: OrderByType.byName,
//               ),
//               const SizedBox(width: 30),
//               _SelectionItem(
//                 text: 'by missing %',
//                 type: OrderByType.byCompleteness,
//               ),
//               const SizedBox(width: 30),
//               _SelectionItem(
//                 text: 'by selection',
//                 type: OrderByType.bySelected,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SelectionItem extends StatefulWidget {
//   final String text;
//   final OrderByType type;
//   _SelectionItem({
//     Key? key,
//     required this.text,
//     required this.type,
//   }) : super(key: key);

//   @override
//   __SelectionItemState createState() => __SelectionItemState();
// }

// class __SelectionItemState extends State<_SelectionItem> {
//   bool ascendent = true;

//   SummaryController summaryController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 140,
//       child: RawMaterialButton(
//         onPressed: () {
//           if (widget.type == summaryController.orderType) {
//             ascendent = !ascendent;
//           }
//           summaryController.changeStationsOrder(widget.type, ascendent);
//         },
//         fillColor: summaryController.orderType == widget.type
//             ? pColorDark
//             : pColorLight,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Text(
//               widget.text,
//               style: TextStyle(
//                 color: summaryController.orderType == widget.type
//                     ? pColorLight
//                     : pColorDark,
//               ),
//             ),
//             Transform.rotate(
//               angle: ascendent ? 0 : pi,
//               child: Icon(
//                 Icons.filter_list,
//                 color: summaryController.orderType == widget.type
//                     ? pColorLight
//                     : pColorDark,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
