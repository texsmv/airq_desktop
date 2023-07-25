import 'package:airq_ui/models/window_model.dart';
import 'package:flutter/rendering.dart';

class IPoint {
  WindowModel data;
  Offset coordinates;
  Offset localCoordinates;
  Offset highlightedCoordinates;
  Offset outlierCoordinates;
  late Offset canvasHighlightedCoordinates;
  late Offset canvasOutlierCoordinates;
  late Offset canvasCoordinates;
  late Offset canvasLocalCoordinates;
  IPoint({
    required this.data,
    required this.coordinates,
    required this.localCoordinates,
    required this.highlightedCoordinates,
    required this.outlierCoordinates,
  });

  /// cluster id
  ///
  /// -1 means it's an outlier
  String? cluster;

  int isOutlier = 0; // 1, 2 for lower and upper outliers
  bool selected = false;
  bool isHighlighted = false;
  bool withinFilter = true;

  Offset getCoords(int mode) {
    if (mode == 0) {
      return coordinates;
    } else if (mode == 1) {
      return localCoordinates;
    } else if (mode == 2) {
      return highlightedCoordinates;
    } else {
      return outlierCoordinates;
    }
  }

  Offset getCanvasCoords(int mode) {
    if (mode == 0) {
      return canvasCoordinates;
    } else if (mode == 1) {
      return canvasLocalCoordinates;
    } else if (mode == 2) {
      return canvasHighlightedCoordinates;
    } else {
      return canvasOutlierCoordinates;
    }
  }
}
