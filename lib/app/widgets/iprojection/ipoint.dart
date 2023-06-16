import 'package:airq_ui/models/window_model.dart';
import 'package:flutter/rendering.dart';

class IPoint {
  WindowModel data;
  Offset coordinates;
  Offset localCoordinates;
  late Offset canvasCoordinates;
  late Offset canvasLocalCoordinates;
  IPoint({
    required this.data,
    required this.coordinates,
    required this.localCoordinates,
  });

  /// cluster id
  ///
  /// -1 means it's an outlier
  String? cluster;

  bool isOutlier = false;
  bool selected = false;
  bool isHighlighted = false;
  bool withinFilter = true;
}
