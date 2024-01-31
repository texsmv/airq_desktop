import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IProjectionController extends GetxController {
  IProjectionController({required this.mode});
  final int mode;
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

  RxBool showInfo = false.obs;

  double get minX {
    if (_minX != null) return _minX!;
    List<double> xValues = List.generate(
        points.length, (index) => points[index].getCoords(mode).dx);
    _minX = xValues.reduce(min);
    return _minX!;
  }

  double get maxX {
    if (_maxX != null) return _maxX!;
    List<double> xValues = List.generate(
        points.length, (index) => points[index].getCoords(mode).dx);
    _maxX = xValues.reduce(max);
    return _maxX!;
  }

  double get minY {
    if (_minY != null) return _minY!;
    List<double> yValues = List.generate(
        points.length, (index) => points[index].getCoords(mode).dy);
    _minY = yValues.reduce(min);
    return _minY!;
  }

  double get maxY {
    if (_maxY != null) return _maxY!;
    List<double> yValues = List.generate(
        points.length, (index) => points[index].getCoords(mode).dy);
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
      double x = points[i].getCanvasCoords(mode).dx;
      double y = points[i].getCanvasCoords(mode).dy;

      if (nearest == null) {
        nearest = points[i];
      } else {
        double distance = sqrt(pow((pointer.dx - x), 2).toDouble() +
            pow((pointer.dy - y), 2).toDouble());

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
      double x = points[i].getCanvasCoords(mode).dx;
      double y = points[i].getCanvasCoords(mode).dy;
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
    // if (dashboardController.selectedPoints.isEmpty) {
    spoints = points;
    // } else {
    //   spoints = dashboardController.selectedPoints;
    // }

    bool oneFound = false;
    for (var i = 0; i < spoints.length; i++) {
      if (spoints[i].selected) {
        oneFound = true;
        double x = points[i].getCanvasCoords(mode).dx;
        double y = points[i].getCanvasCoords(mode).dy;
        double dist = sqrt(pow(x - tapX, 2) + pow(y - tapY, 2));
        if (dist < minDist) {
          minDist = dist;
          selected = spoints[i];
        }
      }
    }
    // Check all if no one was selected
    if (!oneFound) {
      for (var i = 0; i < spoints.length; i++) {
        oneFound = true;
        double x = points[i].getCanvasCoords(mode).dx;
        double y = points[i].getCanvasCoords(mode).dy;
        double dist = sqrt(pow(x - tapX, 2) + pow(y - tapY, 2));
        if (dist < minDist) {
          minDist = dist;
          selected = spoints[i];
        }
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
        onPointsSelected(selectedPoints);
        currSelectedPoints = selectedPoints;

        Get.find<IProjectionController>(tag: 'global').showInfo.value = false;
        Get.find<IProjectionController>(tag: 'local').showInfo.value = false;
        // Get.find<IProjectionController>(tag: 'filter').showInfo.value = false;
        // Get.find<IProjectionController>(tag: 'outlier').showInfo.value = false;

        if (currSelectedPoints.isNotEmpty) {
          showInfo.value = true;
        }
        selectionBeginPosition = const Offset(0, 0);
        selectionEndPosition = const Offset(0, 0);
        allowSelection = true;

        List<Offset> limits = detectBoundaries(selectedPoints);
        if (limits.isNotEmpty) {
          selectedBoxMinOffset = limits[0];
          selectedBoxMaxOffset = limits[1];
          getSelectionStats(selectedPoints);
        }
      }
    }
  }

  void getSelectionStats(List<IPoint> points) {
    for (var poll in datasetController.pollutants) {
      // List<double> means = List.generate(
      //     points.length, (index) => points[index].data.values[poll.id]);
      List<double> polValues = [];
      for (var point in points) {
        polValues.addAll(point.data.values[poll.id]!);
      }
      double pmean = calculateMean(polValues);
      double pstd = calculateStandardDeviation(polValues);

      selectionStats[poll.id] = Offset(pmean, pstd);
    }
  }

  List<Offset> detectBoundaries(List<IPoint> points) {
    if (points.isEmpty) {
      return [];
    }
    double min_x, min_y, max_x, max_y;
    min_x = max_x = points[0].getCanvasCoords(mode).dx;
    min_y = max_y = points[0].getCanvasCoords(mode).dy;

    for (var point in points) {
      double x = point.getCanvasCoords(mode).dx;
      double y = point.getCanvasCoords(mode).dy;

      if (x < min_x) {
        min_x = x;
      } else if (x > max_x) {
        max_x = x;
      }

      if (y < min_y) {
        min_y = y;
      } else if (y > max_y) {
        max_y = y;
      }
    }
    return [Offset(min_x, min_y), Offset(max_x, max_y)];
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
      currentCoordinates[i] = points[i].getCoords(mode);
      oldCoordinates[i] = points[i].getCoords(mode);
      newCoordinates[i] = points[i].getCoords(mode);
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
      newCoordinates[i] = points[i].getCoords(mode);

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

  Offset selectedBoxMinOffset = Offset.zero;
  Offset selectedBoxMaxOffset = Offset.zero;
  Map<int, Offset> selectionStats = {};
  List<IPoint> currSelectedPoints = [];
}
