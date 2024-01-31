// import 'dart:math';

// import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
// import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
// import 'package:airq_ui/controllers/dataset_controller.dart';
// import 'package:easy_debounce/easy_debounce.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SubsetProjectionController extends GetxController {
//   SubsetProjectionController() {
//     xcoords = List<double>.generate(
//         points.length, (index) => points[index].coordinates.dx);
//     ycoords = List<double>.generate(
//         points.length, (index) => points[index].coordinates.dy);
//     maxX = xcoords.reduce(max);
//     maxY = ycoords.reduce(max);
//     minX = xcoords.reduce(min);
//     minY = ycoords.reduce(min);
//   }
//   late List<double> xcoords, ycoords;
//   List<IPoint> get points => datasetController.subset!;
//   late void Function(List<IPoint> points) onPointsSelected;
//   bool shouldRepaint = false;
//   late double minX, maxX, minY, maxY;

//   RxBool _allowSelection = true.obs;
//   bool get allowSelection => _allowSelection.value;
//   set allowSelection(bool value) => _allowSelection.value = value;

//   Rx<Offset> _selectionBeginPosition = Offset(0, 0).obs;
//   Offset get selectionBeginPosition => _selectionBeginPosition.value;
//   set selectionBeginPosition(Offset value) =>
//       _selectionBeginPosition.value = value;
//   Rx<Offset> _selectionEndPosition = Offset(0, 0).obs;
//   Offset get selectionEndPosition => _selectionEndPosition.value;
//   set selectionEndPosition(Offset value) => _selectionEndPosition.value = value;

//   RxBool _flipHorizontally = false.obs;
//   bool get flipHorizontally => _flipHorizontally.value;
//   set flipHorizontally(bool value) => _flipHorizontally.value = value;
//   RxBool _flipVertically = false.obs;
//   bool get flipVertically => _flipVertically.value;
//   set flipVertically(bool value) => _flipVertically.value = value;
//   double get selectionWidth =>
//       (selectionEndPosition.dx - selectionBeginPosition.dx).abs();

//   double get selectionHeight =>
//       (selectionEndPosition.dy - selectionBeginPosition.dy).abs();

//   double get selectionHorizontalStart {
//     if (flipHorizontally) {
//       return selectionBeginPosition.dx - selectionWidth;
//     } else {
//       return selectionBeginPosition.dx;
//     }
//   }

//   double get selectionVerticalStart {
//     if (flipVertically) {
//       return selectionBeginPosition.dy - selectionHeight;
//     } else {
//       return selectionBeginPosition.dy;
//     }
//   }

//   void onPointerDown(PointerDownEvent event) {
//     if (allowSelection) {
//       selectionBeginPosition = event.localPosition;
//     }
//   }

//   void clearSelection() {
//     for (var i = 0; i < points.length; i++) {
//       points[i].selected = false;
//       // points[i].dayModel.isWeekFiltered = false;
//       // points[i].dayModel.isMonthFiltered = false;
//       // points[i].dayModel.isYearFiltered = false;
//     }
//   }

//   IPoint? getNearestPointWithinThreshold(Offset pointer, double threshold) {
//     IPoint? nearest = null;
//     double minDistance = double.infinity;
//     for (var i = 0; i < points.length; i++) {
//       double x = points[i].canvasCoordinates.dx;
//       double y = points[i].canvasCoordinates.dy;

//       if (nearest == null) {
//         nearest = points[i];
//       } else {
//         double distance = sqrt(pow((pointer.dx - x), 2).toDouble() +
//             pow((pointer.dy - y), 2).toDouble());

//         if (minDistance > distance && distance < threshold) {
//           nearest = points[i];
//           minDistance = distance;
//         }
//       }
//     }

//     return nearest;
//   }

//   List<IPoint> selectPoints() {
//     List<IPoint> selected = [];
//     for (var i = 0; i < points.length; i++) {
//       double x = points[i].canvasCoordinates.dx;
//       double y = points[i].canvasCoordinates.dy;
//       if ((x >
//               min(selectionHorizontalStart,
//                   selectionHorizontalStart + selectionWidth)) &&
//           (x <
//               max(selectionHorizontalStart,
//                   selectionHorizontalStart + selectionWidth)) &&
//           (y >
//               min(selectionVerticalStart,
//                   selectionVerticalStart + selectionHeight)) &&
//           (y <
//               max(selectionVerticalStart,
//                   selectionVerticalStart + selectionHeight))) {
//         if (points[i].withinFilter) {
//           selected.add(points[i]);
//           points[i].selected = true;
//         }
//       }
//     }
//     return selected;
//   }

//   void onPointerUp(PointerUpEvent event) {
//     if (allowSelection) {
//       clearSelection();
//       final List<IPoint> selectedPoints = selectPoints();
//       if (onPointsSelected != null) {
//         onPointsSelected(selectedPoints);
//       }
//       selectionBeginPosition = Offset(0, 0);
//       selectionEndPosition = Offset(0, 0);
//       allowSelection = true;
//     }
//   }

//   void onPointerMove(PointerMoveEvent event) {
//     if (allowSelection) {
//       selectionEndPosition = event.localPosition;
//       if ((selectionEndPosition.dx - selectionBeginPosition.dx).isNegative) {
//         flipHorizontally = true;
//       } else {
//         flipHorizontally = false;
//       }
//       if ((selectionEndPosition.dy - selectionBeginPosition.dy).isNegative) {
//         flipVertically = true;
//       } else {
//         flipVertically = false;
//       }
//     }
//   }

//   void repaint() {
//     shouldRepaint = true;
//     update();
//     Future.delayed(Duration(milliseconds: 250))
//         .then((value) => shouldRepaint = false);
//   }

//   // void initCoordinates() {
//   //   currentCoordinates = List.generate(points.length, (index) => Offset(0, 0));
//   //   for (var i = 0; i < points.length; i++) {
//   //     if (isLocal) {
//   //       currentCoordinates[i] = points[i].localCoordinates;
//   //       oldCoordinates[i] = points[i].localCoordinates;
//   //       newCoordinates[i] = points[i].localCoordinates;
//   //     } else {
//   //       currentCoordinates[i] = points[i].coordinates;
//   //       oldCoordinates[i] = points[i].coordinates;
//   //       newCoordinates[i] = points[i].coordinates;
//   //     }
//   //   }
//   //   // print("INIT DONE");
//   //   // print(currentCoordinates);
//   //   // print(newCoordinates);
//   // }

//   late List<Offset> currentCoordinates;

//   DatasetController get datasetController => Get.find();
// }
