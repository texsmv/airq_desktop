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

  String? get cluster => data.cluster;
  int get isOutlier => data.isOutlier;
  bool get selected => data.selected;
  bool get isHighlighted => data.isHighlighted;
  bool get withinFilter => data.withinFilter;

  set cluster(String? v) => data.cluster = v;
  set isOutlier(int v) => data.isOutlier = v;
  set selected(bool v) => data.selected = v;
  set isHighlighted(bool v) => data.isHighlighted = v;
  set withinFilter(bool v) => data.withinFilter = v;

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
