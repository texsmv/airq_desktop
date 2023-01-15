import 'dart:ui';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

class PDialog extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  const PDialog({
    Key? key,
    required this.child,
    this.width = 400,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: BlurryContainer(
          color: const Color.fromRGBO(222, 222, 222, 0.8),
          blur: 20,
          elevation: 2,
          height: height,
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: child,
        ),
      ),
    );
  }
}
