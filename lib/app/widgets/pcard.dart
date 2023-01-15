import 'package:airq_ui/app/constants/colors.dart';
import 'package:flutter/material.dart';

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
}
