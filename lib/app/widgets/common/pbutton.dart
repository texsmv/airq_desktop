import 'package:airq_ui/app/constants/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nice_buttons/nice_buttons.dart';

class PButton extends StatelessWidget {
  final String text;
  final Function onTap;

  late Color fillColor;
  late Color textColor;

  final double width;
  final double height;

  PButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.fillColor = pColorPrimary,
    this.textColor = Colors.white,
    this.width = 120,
    this.height = 40,
  }) : super(key: key);

  PButton.light({
    Key? key,
    required this.text,
    required this.onTap,
    this.width = 120,
    this.height = 40,
  }) : super(key: key) {
    fillColor = pColorLight;
    textColor = Colors.white;
  }
  PButton.dark({
    Key? key,
    required this.text,
    required this.onTap,
    this.width = 120,
    this.height = 40,
  }) : super(key: key) {
    fillColor = pColorAccent;
    textColor = Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: NiceButtons(
        stretch: true,
        width: width,
        height: height,
        gradientOrientation: GradientOrientation.Horizontal,
        startColor: fillColor,
        endColor: fillColor,
        borderColor: fillColor.withOpacity(0.5),
        onTap: (finish) {
          onTap();
        },
        child: AutoSizeText(
          text,
          minFontSize: 8,
          maxLines: 1,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
