// import 'package:airq_ui/app/constants/colors.dart';
// import 'package:flutter/material.dart';

// class PButton extends StatelessWidget {
//   final Function onTap;
//   final bool light;
//   final String text;
//   const PButton(
//       {Key? key, required this.onTap, required this.text, this.light = true})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 140,
//       child: RawMaterialButton(
//         onPressed: () {
//           onTap();
//         },
//         fillColor: !light ? pColorDark : pColorLight,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Text(
//               text,
//               style: TextStyle(
//                 color: !light ? pColorLight : pColorDark,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
