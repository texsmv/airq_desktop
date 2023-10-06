import 'dart:convert';

class WindowModel {
  late int id;
  late DateTime beginDate;
  // late Map<int, double> local_x;
  // late Map<int, double> local_y;
  late double local_x;
  late double local_y;
  late double global_x;
  late double global_y;

  late int stationId;

  Map<int, int> iaqis = {};
  int aqi = -1;

  Map<int, List<double>> values = {};
  Map<int, List<double>> smoothedValues = {};

  // cluster id
  //
  //  -1 means it's an outlier
  String? cluster;

  int isOutlier = 0; // 1, 2 for lower and upper outliers
  bool selected = false;
  bool isHighlighted = false;
  bool withinFilter = true;

  WindowModel({
    required this.id,
    required this.beginDate,
    required this.stationId,
  }) {
    local_x = 0;
    local_y = 0;
    global_x = 0;
    global_y = 0;
  }

  void addPollutant(
    int polutantId,
    List<double> polValues,
    List<double> polSmoothValues,
  ) {
    values[polutantId] = polValues;
    smoothedValues[polutantId] = polSmoothValues;
  }
}
