import 'dart:io';
import 'dart:typed_data';

import 'package:airq_ui/app/ui_utils.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:airq_ui/app/constants/colors.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widget_to_image/widget_to_image.dart';

class PCard extends StatefulWidget {
  final Widget? child;
  final double borderRadius;
  final Color color;
  final double? height;
  final double? width;
  const PCard({
    Key? key,
    this.child,
    this.borderRadius = 8,
    this.color = pColorBackground,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<PCard> createState() => _PCardState();
}

class _PCardState extends State<PCard> {
  bool hide = false;
  bool hovered = false;
  static const double borderW = 20;
  static const double hideSize = 40;
  GlobalKey _globalKey = GlobalKey();

  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          hovered = false;
        });
      },
      child: RepaintBoundary(
        key: _globalKey,
        child: Container(
            height: hide ? hideSize : widget.height,
            width: hide ? hideSize : widget.width,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: hide
                ? Center(child: expandIcon())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Visibility(
                          visible: hovered,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: SizedBox(
                            height: borderW,
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                captureIcon(),
                                expandIcon(),
                              ],
                            ),
                          )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: borderW,
                            right: borderW,
                            bottom: borderW,
                          ),
                          child: widget.child ?? SizedBox(),
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }

  Widget expandIcon() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: borderW,
          height: borderW,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(240, 240, 240, 1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              hide ? Icons.add : Icons.remove,
              size: 16,
            ),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          hide = !hide;
        });
      },
    );
  }

  Widget captureIcon() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: borderW,
          height: borderW,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(240, 240, 240, 1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.image,
              size: 12,
            ),
          ),
        ),
      ),
      onTap: () async {
        ByteData byteData =
            await WidgetToImage.repaintBoundaryToImage(_globalKey);
        // await FileSaver.instance.saveFile(String name, Uint8List bytes, String ext, mimeType: MimeType);
        // Directory appDocDir = await getApplicationDocumentsDirectory();
        // String appDocPath = appDocDir.path;
        String imageName = await uiPickString();
        String path = p.join(imageName);
        FileSaver.instance.saveFile(path, byteData.buffer.asUint8List(), 'png');

        Get.showSnackbar(
          GetSnackBar(
            message: 'Saved to download folder as: $path.png',
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}
