import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_controller.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_painter.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double INFO_BOX_HEIGHT = 20;
double INFO_BOX_WIDTH = 130;

class IProjection extends StatefulWidget {
  final List<IPoint> points;
  // the index is the id minus 1
  final void Function(List<IPoint> points) onPointsSelected;
  final void Function(IPoint point) onPointPicked;
  final IProjectionController controller;

  final int mode;
  final bool pickMode;
  const IProjection({
    Key? key,
    required this.points,
    required this.controller,
    required this.onPointsSelected,
    required this.onPointPicked,
    required this.mode,
    required this.pickMode,
  }) : super(key: key);

  @override
  _IProjectionState createState() => _IProjectionState();
}

class _IProjectionState extends State<IProjection>
    with SingleTickerProviderStateMixin {
  IProjectionController get controller => widget.controller;
  DatasetController datasetController = Get.find();

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
      tag: (widget.mode == 1)
          ? 'local'
          : (widget.mode == 0)
              ? 'global'
              : 'filter',
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
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: controller.animationController,
                        builder: (context, constraints) {
                          controller.updatePositions();
                          return CustomPaint(
                            painter: IProjectionPainter(
                              mode: widget.mode,
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
                  Positioned(
                    left: constraints.maxWidth -
                                controller.selectedBoxMaxOffset.dx <
                            INFO_BOX_WIDTH
                        ? constraints.maxWidth - INFO_BOX_WIDTH
                        : controller.selectedBoxMaxOffset.dx,
                    // top: controller.selectedBoxMinOffset.dy - 50,
                    top: getTopDistance(),
                    child: Obx(
                      () => Visibility(
                        visible: controller.showInfo.value,
                        child: Container(
                          width: INFO_BOX_WIDTH,
                          child: Column(
                            children: List.generate(
                              datasetController.pollutants.length,
                              (pindex) => Container(
                                color: Colors.amber.withOpacity(0.6),
                                height: INFO_BOX_HEIGHT,
                                width: INFO_BOX_WIDTH,
                                child: AutoSizeText(
                                  '${datasetController.pollutants[pindex].name}: ${controller.selectionStats[datasetController.pollutants[pindex].id]?.dx.toPrecision(2)} µg/m³',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                  minFontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double getTopDistance() {
    if (controller.selectedBoxMaxOffset.dy >
        INFO_BOX_HEIGHT * datasetController.pollutants.length) {
      return controller.selectedBoxMaxOffset.dy -
          INFO_BOX_HEIGHT * datasetController.pollutants.length;
    } else {
      return controller.selectedBoxMaxOffset.dy - 50;
    }
  }
}
