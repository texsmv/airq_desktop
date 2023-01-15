import 'dart:ui';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/widgets/common/light_button.dart';
import 'package:airq_ui/app/widgets/common/pbutton.dart';
import 'package:airq_ui/app/widgets/common/pdialog.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcceptDialog extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final String content;
  final String acceptText;
  final String cancelText;
  const AcceptDialog({
    Key? key,
    required this.title,
    required this.content,
    this.acceptText = 'accept',
    this.cancelText = 'cancel',
    this.width = 400,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PDialog(
      width: width,
      height: height,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: pColorDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            content,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 14,
              color: pColorText,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PButton(
                text: acceptText,
                onTap: () {
                  Get.back(result: true);
                },
              ),
              PButton(
                fillColor: pColorError,
                text: cancelText,
                onTap: () {
                  Get.back(result: false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
