import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/window_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/colors.dart';

// class AqiChartPainter extends CustomPainter {
//   DatasetController datasetController = Get.find();
//   DashboardController dashboardController = Get.find();
//   late Canvas _canvas;
//   late double _width;
//   late double _height;

//   late double _linesSpace;

//   List<IPoint> get ipoints => datasetController.globalPoints!;
//   int get n_iaqis => datasetController.iaqis!.length;
//   List<int> get pollIds => datasetController.iaqis!.keys.toList();
//   Color normalColor = Color.fromRGBO(190, 190, 190, 1);

//   @override
//   void paint(Canvas canvas, Size size) {
//     _canvas = canvas;
//     _height = size.height;
//     _width = size.width;
//     _linesSpace = _width / (n_iaqis - 1);

//     drawLines();
//   }

//   void drawLines() {
//     for (var i = 0; i < ipoints.length; i++) {
//       if (!ipoints[i].selected) {
//         WindowModel window = ipoints[i].data;

//         Path path = Path();
//         path.moveTo(0, value2Heigh(window.iaqis[pollIds[0]]!.toDouble()));
//         for (int i = 1; i < n_iaqis; ++i) {
//           path.lineTo(i * _linesSpace,
//               value2Heigh(window.iaqis[pollIds[i]]!.toDouble()));
//         }
//         Paint paint = Paint()
//           ..color = normalColor
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 1.5;
//         _canvas.drawPath(
//           path,
//           paint,
//         );
//       }
//     }

//     for (var i = 0; i < ipoints.length; i++) {
//       if (ipoints[i].selected) {
//         IPoint model = ipoints[i];
//         WindowModel window = ipoints[i].data;

//         Path path = Path();
//         path.moveTo(0, value2Heigh(window.iaqis[pollIds[0]]!.toDouble()));
//         for (int i = 1; i < n_iaqis; ++i) {
//           path.lineTo(i * _linesSpace,
//               value2Heigh(window.iaqis[pollIds[i]]!.toDouble()));
//         }

//         Paint paint;

//         if (model.cluster != null) {
//           bool isHighlighted;
//           if (datasetController.selectedWindow != null &&
//               model.data.id == datasetController.selectedWindow!.id) {
//             isHighlighted = true;
//           } else {
//             isHighlighted = false;
//           }
//           if (dashboardController.selectedPoints.isNotEmpty) {
//             if (model.selected) {
//               paint = Paint()
//                 ..color = uiClusterColor(model.cluster!)
//                     .withOpacity(isHighlighted ? 1 : 0.6)
//                 ..style = PaintingStyle.stroke
//                 ..strokeWidth = isHighlighted ? 3.5 : 1.5;
//             } else {
//               paint = Paint()
//                 ..color = normalColor
//                 ..style = PaintingStyle.stroke
//                 ..strokeWidth = isHighlighted ? 3.5 : 1.5;
//             }
//           } else {
//             paint = Paint()
//               ..color = uiClusterColor(model.cluster!)
//                   .withOpacity(isHighlighted ? 1 : 0.6)
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = isHighlighted ? 3.5 : 1.5;
//           }
//         } else {
//           bool isHighlighted;
//           if (datasetController.selectedWindow != null &&
//               model.data.id == datasetController.selectedWindow!.id) {
//             isHighlighted = true;
//           } else {
//             isHighlighted = false;
//           }
//           if (model.selected) {
//             paint = Paint()
//               ..color = pColorPrimary
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = isHighlighted ? 3.5 : 1.5;
//           } else {
//             paint = Paint()
//               ..color = normalColor
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = isHighlighted ? 3.5 : 1.5;
//           }
//         }

//         _canvas.drawPath(
//           path,
//           paint,
//         );
//       }
//     }
//   }

//   double value2Heigh(double value) {
//     return _height - uiRangeConverter(value, 0, 500, 0, _height);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//     // return controller.shouldRepaint;
//   }
// }

class AqiChartPainter extends CustomPainter {
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();
  late Canvas _canvas;
  late double _width;
  late double _height;

  late double _linesSpace;

  List<IPoint> get ipoints => datasetController.filteredPoints;

  int get n_iaqis => datasetController.iaqis!.length;
  List<int> get pollIds => datasetController.iaqis!.keys.toList();
  Color normalColor = Color.fromRGBO(190, 190, 190, 1);

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _height = size.height;
    _width = size.width;
    _linesSpace = _width / (n_iaqis - 1);

    // drawLines();
    if (datasetController.clusterIds.isEmpty) {
      drawSelectedMeans();
    } else {
      drawClustersMeans();
    }
  }

  double calculateMean(List<double> numbers) {
    if (numbers.isEmpty) return 0.0;

    double sum = numbers.reduce((a, b) => a + b);
    return sum / numbers.length;
  }

  double calculateStandardDeviation(List<double> numbers) {
    if (numbers.isEmpty) return 0.0;

    double mean = calculateMean(numbers);
    double variance = 0.0;

    for (var number in numbers) {
      variance += pow(number - mean, 2);
    }

    variance /= numbers.length;

    return sqrt(variance);
  }

  Offset getPointsMeansStds(List<IPoint> points, int pollId) {
    List<double> values = List.generate(
        points.length, (index) => points[index].data.iaqis[pollId]!.toDouble());
    double mean = calculateMean(values);
    double std = calculateStandardDeviation(values);

    return Offset(mean, std);
  }

  void drawSelectedMeans() {
    List<IPoint> points = [];
    for (var i = 0; i < ipoints.length; i++) {
      if (ipoints[i].selected) {
        points.add(ipoints[i]);
      }
    }

    for (int i = 0; i < n_iaqis; ++i) {
      Offset meanStd = getPointsMeansStds(points, pollIds[i]);
      Paint paint = Paint()
        ..color = normalColor
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.5;
      _canvas.drawCircle(
          Offset(i * _linesSpace, value2Heigh(meanStd.dx)), 5, paint);

      paint = Paint()
        ..color = normalColor
        ..style = PaintingStyle.fill
        ..strokeWidth = 4.5;
      _canvas.drawLine(
          Offset(i * _linesSpace, value2Heigh(meanStd.dx - meanStd.dy * 2)),
          Offset(i * _linesSpace, value2Heigh(meanStd.dx + meanStd.dy * 2)),
          paint);
    }
  }

  void drawClustersMeans() {
    for (var k = 0; k < datasetController.clusterIds.length; k++) {
      String clusterId = datasetController.clusterIds[k];
      Offset leftOffset = Offset(7.0 * k, 0);
      ClusterData clusterData = datasetController.clustersData[clusterId]!;
      List<IPoint> points = clusterData.ipoints;

      for (int i = 0; i < n_iaqis; ++i) {
        Offset meanStd = getPointsMeansStds(points, pollIds[i]);
        Paint paint = Paint()
          ..color = clusterData.color
          ..style = PaintingStyle.fill
          ..strokeWidth = 1.5;
        _canvas.drawCircle(
          Offset(i * _linesSpace, value2Heigh(meanStd.dx)) + leftOffset,
          5,
          paint,
        );

        paint = Paint()
          ..color = clusterData.color
          ..style = PaintingStyle.fill
          ..strokeWidth = 3.5;
        _canvas.drawLine(
            Offset(i * _linesSpace, value2Heigh(meanStd.dx - meanStd.dy * 2)) +
                leftOffset,
            Offset(i * _linesSpace, value2Heigh(meanStd.dx + meanStd.dy * 2)) +
                leftOffset,
            paint);
      }
    }
  }

  void drawLines() {
    for (var i = 0; i < ipoints.length; i++) {
      if (!ipoints[i].selected) {
        WindowModel window = ipoints[i].data;

        Path path = Path();
        path.moveTo(0, value2Heigh(window.iaqis[pollIds[0]]!.toDouble()));
        for (int i = 1; i < n_iaqis; ++i) {
          path.lineTo(i * _linesSpace,
              value2Heigh(window.iaqis[pollIds[i]]!.toDouble()));
        }
        Paint paint = Paint()
          ..color = normalColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        _canvas.drawPath(
          path,
          paint,
        );
      }
    }

    for (var i = 0; i < ipoints.length; i++) {
      if (ipoints[i].selected) {
        IPoint model = ipoints[i];
        WindowModel window = ipoints[i].data;

        Path path = Path();
        path.moveTo(0, value2Heigh(window.iaqis[pollIds[0]]!.toDouble()));
        for (int i = 1; i < n_iaqis; ++i) {
          path.lineTo(i * _linesSpace,
              value2Heigh(window.iaqis[pollIds[i]]!.toDouble()));
        }

        Paint paint;

        if (model.cluster != null) {
          bool isHighlighted;
          if (datasetController.selectedWindow != null &&
              model.data.id == datasetController.selectedWindow!.id) {
            isHighlighted = true;
          } else {
            isHighlighted = false;
          }
          if (dashboardController.selectedPoints.isNotEmpty) {
            if (model.selected) {
              paint = Paint()
                ..color = uiClusterColor(model.cluster!)
                    .withOpacity(isHighlighted ? 1 : 0.6)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isHighlighted ? 3.5 : 1.5;
            } else {
              paint = Paint()
                ..color = normalColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = isHighlighted ? 3.5 : 1.5;
            }
          } else {
            paint = Paint()
              ..color = uiClusterColor(model.cluster!)
                  .withOpacity(isHighlighted ? 1 : 0.6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isHighlighted ? 3.5 : 1.5;
          }
        } else {
          bool isHighlighted;
          if (datasetController.selectedWindow != null &&
              model.data.id == datasetController.selectedWindow!.id) {
            isHighlighted = true;
          } else {
            isHighlighted = false;
          }
          if (model.selected) {
            paint = Paint()
              ..color = pColorPrimary
              ..style = PaintingStyle.stroke
              ..strokeWidth = isHighlighted ? 3.5 : 1.5;
          } else {
            paint = Paint()
              ..color = normalColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = isHighlighted ? 3.5 : 1.5;
          }
        }

        _canvas.drawPath(
          path,
          paint,
        );
      }
    }
  }

  double value2Heigh(double value) {
    return _height - uiRangeConverter(value, 0, 500, 0, _height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
    // return controller.shouldRepaint;
  }
}
