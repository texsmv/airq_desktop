import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IProjectionController extends GetxController {
  IProjectionController({required this.isLocal});
  final bool isLocal;
  late List<IPoint> points;
  late List<Offset> currentCoordinates;
  late List<Offset> newCoordinates;
  late List<Offset> oldCoordinates;
  late void Function(List<IPoint> points) onPointsSelected;
  late void Function(IPoint point) onPointPicked;
  late bool pickMode;
  bool shouldRepaint = false;
  bool showNjStructure = false;
  double? _minX;
  double? _maxX;
  double? _minY;
  double? _maxY;

  double get minX {
    if (_minX != null) return _minX!;
    List<double> xValues = List.generate(
        points.length,
        (index) => isLocal
            ? points[index].localCoordinates.dx
            : points[index].coordinates.dx);
    _minX = xValues.reduce(min);
    return _minX!;
  }

  double get maxX {
    if (_maxX != null) return _maxX!;
    List<double> xValues = List.generate(
        points.length,
        (index) => isLocal
            ? points[index].localCoordinates.dx
            : points[index].coordinates.dx);
    _maxX = xValues.reduce(max);
    return _maxX!;
  }

  double get minY {
    if (_minY != null) return _minY!;
    List<double> yValues = List.generate(
        points.length,
        (index) => isLocal
            ? points[index].localCoordinates.dy
            : points[index].coordinates.dy);
    _minY = yValues.reduce(min);
    return _minY!;
  }

  double get maxY {
    if (_maxY != null) return _maxY!;
    List<double> yValues = List.generate(
        points.length,
        (index) => isLocal
            ? points[index].localCoordinates.dy
            : points[index].coordinates.dy);
    _maxY = yValues.reduce(max);
    return _maxY!;
  }

  late AnimationController animationController;

  RxBool _allowSelection = true.obs;
  bool get allowSelection => _allowSelection.value;
  set allowSelection(bool value) => _allowSelection.value = value;

  Rx<Offset> _selectionBeginPosition = Offset(0, 0).obs;
  Offset get selectionBeginPosition => _selectionBeginPosition.value;
  set selectionBeginPosition(Offset value) =>
      _selectionBeginPosition.value = value;
  Rx<Offset> _selectionEndPosition = Offset(0, 0).obs;
  Offset get selectionEndPosition => _selectionEndPosition.value;
  set selectionEndPosition(Offset value) => _selectionEndPosition.value = value;

  RxBool _flipHorizontally = false.obs;
  bool get flipHorizontally => _flipHorizontally.value;
  set flipHorizontally(bool value) => _flipHorizontally.value = value;
  RxBool _flipVertically = false.obs;
  bool get flipVertically => _flipVertically.value;
  set flipVertically(bool value) => _flipVertically.value = value;
  double get selectionWidth =>
      (selectionEndPosition.dx - selectionBeginPosition.dx).abs();

  double get selectionHeight =>
      (selectionEndPosition.dy - selectionBeginPosition.dy).abs();

  double get selectionHorizontalStart {
    if (flipHorizontally) {
      return selectionBeginPosition.dx - selectionWidth;
    } else {
      return selectionBeginPosition.dx;
    }
  }

  double get selectionVerticalStart {
    if (flipVertically) {
      return selectionBeginPosition.dy - selectionHeight;
    } else {
      return selectionBeginPosition.dy;
    }
  }

  void onPointerDown(PointerDownEvent event) {
    if (pickMode) {
    } else {
      if (allowSelection) {
        selectionBeginPosition = event.localPosition;
      }
    }
  }

  void clearSelection() {
    for (var i = 0; i < points.length; i++) {
      points[i].selected = false;
      // points[i].dayModel.isWeekFiltered = false;
      // points[i].dayModel.isMonthFiltered = false;
      // points[i].dayModel.isYearFiltered = false;
    }
  }

  IPoint? getNearestPointWithinThreshold(Offset pointer, double threshold) {
    IPoint? nearest = null;
    double minDistance = double.infinity;
    for (var i = 0; i < points.length; i++) {
      double x = isLocal
          ? points[i].canvasLocalCoordinates.dx
          : points[i].canvasCoordinates.dx;
      double y = isLocal
          ? points[i].canvasLocalCoordinates.dy
          : points[i].canvasCoordinates.dy;

      if (nearest == null) {
        nearest = points[i];
      } else {
        double distance = sqrt(pow((pointer.dx - x), 2).toDouble() +
            pow((pointer.dy - y), 2).toDouble());

        print(distance);
        if (minDistance > distance && distance < threshold) {
          nearest = points[i];
          minDistance = distance;
        }
      }
    }

    return nearest;
  }

  List<IPoint> selectPoints() {
    List<IPoint> selected = [];
    for (var i = 0; i < points.length; i++) {
      double x = isLocal
          ? points[i].canvasLocalCoordinates.dx
          : points[i].canvasCoordinates.dx;
      double y = isLocal
          ? points[i].canvasLocalCoordinates.dy
          : points[i].canvasCoordinates.dy;
      if ((x >
              min(selectionHorizontalStart,
                  selectionHorizontalStart + selectionWidth)) &&
          (x <
              max(selectionHorizontalStart,
                  selectionHorizontalStart + selectionWidth)) &&
          (y >
              min(selectionVerticalStart,
                  selectionVerticalStart + selectionHeight)) &&
          (y <
              max(selectionVerticalStart,
                  selectionVerticalStart + selectionHeight))) {
        if (points[i].withinFilter) {
          selected.add(points[i]);
          points[i].selected = true;
        }
      }
    }
    return selected;
  }

  IPoint pickedPoint(double tapX, double tapY) {
    late IPoint selected;
    double minDist = 10000000; // infinite
    late List<IPoint> spoints;
    if (dashboardController.selectedPoints.isEmpty) {
      spoints = points;
    } else {
      spoints = dashboardController.selectedPoints;
    }
    for (var i = 0; i < spoints.length; i++) {
      double x = isLocal
          ? spoints[i].canvasLocalCoordinates.dx
          : spoints[i].canvasCoordinates.dx;
      double y = isLocal
          ? spoints[i].canvasLocalCoordinates.dy
          : spoints[i].canvasCoordinates.dy;
      double dist = sqrt(pow(x - tapX, 2) + pow(y - tapY, 2));
      if (dist < minDist) {
        minDist = dist;
        selected = spoints[i];
      }
    }
    return selected;
  }

  void onPointerUp(PointerUpEvent event) {
    if (pickMode) {
      IPoint point =
          pickedPoint(event.localPosition.dx, event.localPosition.dy);
      onPointPicked(point);
    } else {
      if (allowSelection) {
        clearSelection();
        final List<IPoint> selectedPoints = selectPoints();
        if (onPointsSelected != null) {
          onPointsSelected(selectedPoints);
        }
        selectionBeginPosition = Offset(0, 0);
        selectionEndPosition = Offset(0, 0);
        allowSelection = true;
      }
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (!pickMode) {
      if (allowSelection) {
        selectionEndPosition = event.localPosition;
        if ((selectionEndPosition.dx - selectionBeginPosition.dx).isNegative) {
          flipHorizontally = true;
        } else {
          flipHorizontally = false;
        }
        if ((selectionEndPosition.dy - selectionBeginPosition.dy).isNegative) {
          flipVertically = true;
        } else {
          flipVertically = false;
        }
      }
    }
  }

  void onPointerHover(PointerHoverEvent event) {
    EasyDebounce.debounce('NearestPoint', Duration(milliseconds: 200), () {
      // IPoint? nearestPoint =
      //     getNearestPointWithinThreshold(event.localPosition, 100);
      // if (nearestPoint != null) {
      //   nearestPoint.isHighlighted = true;
      //   if (Get.find<DashboardController>().infoPoint != null) {
      //     Get.find<DashboardController>().infoPoint!.isHighlighted = false;
      //   }
      //   Get.find<DashboardController>().infoPoint = nearestPoint;
      //   Get.find<DashboardController>().update();
      // } else {
      //   // if (Get.find<DashboardController>().infoPoint != null) {
      //   //   Get.find<DashboardController>().infoPoint!.isHighlighted = false;
      //   // }
      //   Get.find<DashboardController>().infoPoint = null;
      // }
    });
  }

  void repaint() {
    shouldRepaint = true;
    update();
    Future.delayed(Duration(milliseconds: 250))
        .then((value) => shouldRepaint = false);
  }

  void initCoordinates() {
    currentCoordinates = List.generate(points.length, (index) => Offset(0, 0));
    oldCoordinates = List.generate(points.length, (index) => Offset(0, 0));
    newCoordinates = List.generate(points.length, (index) => Offset(0, 0));
    for (var i = 0; i < points.length; i++) {
      if (isLocal) {
        currentCoordinates[i] = points[i].localCoordinates;
        oldCoordinates[i] = points[i].localCoordinates;
        newCoordinates[i] = points[i].localCoordinates;
      } else {
        currentCoordinates[i] = points[i].coordinates;
        oldCoordinates[i] = points[i].coordinates;
        newCoordinates[i] = points[i].coordinates;
      }
    }
    // print("INIT DONE");
    // print(currentCoordinates);
    // print(newCoordinates);
  }

  void updateCoordinates() {
    _maxX = null;
    _minX = null;
    _maxY = null;
    _minY = null;
    newCoordinates = List.generate(points.length, (index) => Offset(0, 0));
    for (var i = 0; i < points.length; i++) {
      if (isLocal) {
        newCoordinates[i] = points[i].localCoordinates;
      } else {
        newCoordinates[i] = points[i].coordinates;
      }
      oldCoordinates[i] = currentCoordinates[i];
      // if (i == 0) {
      //   print(newCoordinates[i]);
      //   print(oldCoordinates[i]);
      // }
    }
    animationController.reset();
    shouldRepaint = true;
    animationController.forward();
  }

  void initAnimation(TickerProvider vsync) {
    animationController = AnimationController(
        vsync: vsync, duration: Duration(milliseconds: 1000));
    // animationController.addListener(() {
    //   // print("up");
    //   updatePositions();
    // });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        shouldRepaint = false;
        showNjStructure = true;
      } else {
        showNjStructure = false;
      }
    });
  }

  void updatePositions() {
    for (var i = 0; i < points.length; i++) {
      currentCoordinates[i] = oldCoordinates[i] +
          Offset(
              (newCoordinates[i].dx - oldCoordinates[i].dx) *
                  animationController.value,
              (newCoordinates[i].dy - oldCoordinates[i].dy) *
                  animationController.value);
    }
  }

  DatasetController get datasetController => Get.find();
  DashboardController get dashboardController => Get.find();
}
