import 'dart:io';
import 'dart:typed_data';

import 'package:airq_ui/app/ui_utils.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:airq_ui/app/constants/colors.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:widget_to_image/widget_to_image.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class PCard extends StatefulWidget {
  final Widget? child;
  final double borderRadius;
  final Color color;
  final double? height;
  final double? width;
  final bool expand;
  final int flex;
  const PCard({
    Key? key,
    this.child,
    this.borderRadius = 8,
    this.color = pColorBackground,
    this.height,
    this.width,
    this.expand = false,
    this.flex = 1,
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

  WidgetsToImageController controller = WidgetsToImageController();

  Widget build(BuildContext context) {
    Widget child = MouseRegion(
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
      child: WidgetsToImage(
        controller: controller,
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
    if (widget.expand && !hide) {
      child = Expanded(
        child: child,
        flex: widget.flex,
      );
    }
    return child;
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
        // ByteData byteData =
        // await WidgetToImage.repaintBoundaryToImage(_globalKey);

        await controller.capture();
        Uint8List? bytes = await controller.capture();

        // await FileSaver.instance.saveFile(String name, Uint8List bytes, String ext, mimeType: MimeType);
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        String imageName = await uiPickString();
        String path = p.join(imageName);
        FileSaver.instance.saveFile(
            // name: path, bytes: byteData.buffer.asUint8List(), ext: 'png');
            name: path,
            bytes: bytes,
            ext: 'png');

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
