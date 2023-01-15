import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_controller.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IProjection extends StatefulWidget {
  final List<IPoint> points;
  // the index is the id minus 1
  final void Function(List<IPoint> points) onPointsSelected;
  final void Function(IPoint point) onPointPicked;
  final IProjectionController controller;
  final bool isLocal;
  final bool pickMode;
  const IProjection({
    Key? key,
    required this.points,
    required this.controller,
    required this.onPointsSelected,
    required this.onPointPicked,
    required this.isLocal,
    required this.pickMode,
  }) : super(key: key);

  @override
  _IProjectionState createState() => _IProjectionState();
}

class _IProjectionState extends State<IProjection>
    with SingleTickerProviderStateMixin {
  IProjectionController get controller => widget.controller;

  @override
  void initState() {
    controller.initAnimation(this);
    controller.points = widget.points;
    controller.onPointsSelected = widget.onPointsSelected;
    controller.onPointPicked = widget.onPointPicked;
    controller.pickMode = widget.pickMode;
    controller.initCoordinates();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IProjection oldWidget) {
    controller.points = widget.points;
    controller.updateCoordinates();
    // controller.nodes = widget.nodes;
    controller.onPointsSelected = widget.onPointsSelected;
    controller.onPointPicked = widget.onPointPicked;
    controller.pickMode = widget.pickMode;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IProjectionController>(
      tag: widget.isLocal ? 'local' : 'global',
      builder: (_) => Container(
        width: double.infinity,
        height: double.infinity,
        // color: Colors.blue,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Listener(
              onPointerDown: controller.onPointerDown,
              onPointerUp: controller.onPointerUp,
              onPointerMove: controller.onPointerMove,
              onPointerHover: controller.onPointerHover,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: controller.animationController,
                        builder: (context, constraints) {
                          controller.updatePositions();
                          return CustomPaint(
                            painter: IProjectionPainter(
                              isLocal: widget.isLocal,
                            ),
                            willChange: false,
                            isComplex: true,
                          );
                        },
                      ),
                    ),
                  ),
                  Obx(
                    () => Positioned(
                      left: controller.selectionHorizontalStart,
                      top: controller.selectionVerticalStart,
                      child: Visibility(
                        visible: controller.allowSelection,
                        // visible: true,
                        child: Container(
                          color: Colors.blue.withAlpha(120),
                          width: controller.selectionWidth,
                          height: controller.selectionHeight,
                          // width: 100,
                          // height: 100,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
