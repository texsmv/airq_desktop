import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:airq_ui/api/app_repository.dart';
import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/list_shape_ext.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/common/pbutton.dart';
import 'package:airq_ui/app/widgets/common/pdialog.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/models/dataset_model.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:airq_ui/models/station_model.dart';
import 'package:airq_ui/models/window_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';
import 'package:random_color/random_color.dart';

import '../app/constants/constants.dart';

class DatasetController extends GetxController {
  Map<String, List<IPoint>> get clusters => _clusters;
  Map<int, double> get minValues => _minValue;
  Map<int, double> get maxValues => _maxValue;
  double get minValue => _minValue[_projectedPollutant.id]!;
  double get maxValue => _maxValue[_projectedPollutant.id]!;

  DateTimeRange get dateRange =>
      DateTimeRange(start: _beginDate, end: _endDate);

  // double get minMeansValue => _minValue[_projectedPollutant.id]!;
  // double get maxMeansValue => _maxValue[_projectedPollutant.id]!;
  double? minMeansValue;
  double? maxMeansValue;
  List<StationModel> get selectedStations => stations;
  List<StationModel> get nonEmptyStations {
    List<StationModel> stationsE = [];
    for (var i = 0; i < _points!.length; i++) {
      stationsE.add(windowsStations[_points![i].data.id]!);
    }
    var seen = Set<String>();
    List<StationModel> uniquelist =
        stationsE.where((stat) => seen.add(stat.id.toString())).toList();

    return uniquelist;
  }

  List<DatasetModel> get datasets => _datasets;
  List<IPoint>? get globalPoints => _points;
  List<StationModel> get stations => _stations;
  List<PollutantModel> get pollutants => _pollutants;
  List<DateTime> get yearRange => [_minYear!, _maxYear!];
  List<DateTime> get monthRange => [_minMonth!, _maxMonth!];
  Granularity get granularity => _granularity;
  PollutantModel get projectedPollutant => _projectedPollutant;
  List<PollutantModel> get selectedPollutants => _selectedPollutants;
  List<WindowModel> get allWindows => _allWindows;
  List<String> get clusterIds => _clusters.keys.toList();
  List<int> get years {
    // int n = (_endDate.difference(_beginDate).inDays / 365).ceil();
    int n = _endDate.year - _beginDate.year + 1;
    return List.generate(
        n, (i) => _beginDate.add(Duration(days: 366 * i)).year);
  }

  Map<String, Color> get clusterColors => _clusterColors;
  DatasetModel get dataset => _dataset!;

  @override
  void onInit() {
    super.onInit();
  }

  void getMeanAqiPerStation() {
    Map<int, double> values = {};
    for (var i = 0; i < selectedStations.length; i++) {
      values[selectedStations[i].id] = 0;
    }
    for (var i = 0; i < globalPoints!.length; i++) {
      values[globalPoints![i].data.stationId] = 0;
    }
  }

  Future<void> loadDatasets() async {
    _datasets = await repositoryDatasets();
    // List<dynamic> items = jsonDecode(data['data']);
    // _datasets = List.generate(
    //     items.length, (index) => DatasetModel.fromJson(items[index]));
  }

  Future<Map<String, List<dynamic>>> getCorrelationMatrix(
      List<IPoint> points) async {
    final List<int> positions =
        List.generate(points.length, (index) => points[index].data.id);
    Map<String, List<dynamic>> map =
        await repositoryCorrelationMatrix(positions);
    return map;
    // List<double> minv = List<double>.from(map['minv']!);
    // List<double> maxv = List<double>.from(map['maxv']!);
    // List<double> meanv = List<double>.from(map['meanv']!);
    // List<double> stdv = List<double>.from(map['stdv']!);
    // print(minv);
    // print(maxv);
    // print(meanv);
    // print(stdv);

    // return map['corrMatrix']!;
  }

  Future<void> projectSeries() async {
    TextEditingController deltaController =
        TextEditingController(text: pDelta.toString());
    TextEditingController betaController =
        TextEditingController(text: pBeta.toString());
    List<bool> selected = List.generate(pollutants.length, (index) => false);
    int neighbors = 10;
    List<int> selectedPollutants = await Get.dialog(
      PDialog(
        height: 550,
        child: GetBuilder<DatasetController>(
          id: 'dialog',
          builder: (_) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Umap neighbors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: pColorPrimary,
                    ),
                  ),
                  PButton(
                      text: neighbors.toString(),
                      onTap: () async {
                        neighbors = await uiPickNumberInt(5, 100);
                        update(['dialog']);
                      })
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Series',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: pColorPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: pollutants.length,
                itemBuilder: (context, index) {
                  return PButton(
                    fillColor: selected[index] ? pColorPrimary : pColorLight,
                    text: pollutants[index].name,
                    onTap: () {
                      selected[index] = !selected[index];
                      update(['dialog']);
                    },
                  );
                },
              ),

              SizedBox(
                height: 80,
                child: Row(children: [
                  Text('Delta:'),
                  TextField(
                    controller: deltaController,
                  ),
                ]),
              ),
              // const SizedBox(height: 30),
              Spacer(),
              PButton(
                text: 'Get projection',
                onTap: () {
                  bool canProject = false;
                  for (var i = 0; i < pollutants.length; i++) {
                    if (selected[i]) {
                      canProject = true;
                    }
                  }
                  if (!canProject) {
                    Get.snackbar(
                        'Projection', 'You must select at least one option');
                  } else {
                    List<int> positions = [];

                    for (var i = 0; i < pollutants.length; i++) {
                      if (selected[i]) {
                        positions.add(i);
                      }
                    }
                    return Get.back(result: positions);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    uiShowLoader();
    List<dynamic> coords = await repositoryGetProjection(
      pollutantPositions: selectedPollutants,
      neighbors: neighbors,
      beta: double.parse(betaController.text),
      delta: double.parse(deltaController.text),
    );

    for (var i = 0; i < _points!.length; i++) {
      _points![i].coordinates = Offset(coords[i][0], coords[i][1]);
    }
    uiHideLoader();
    Get.find<DashboardController>().update();
  }

  // Future<void> changeSpatioTemporalSettings() async {
  //   TextEditingController deltaController =
  //       TextEditingController(text: pDelta.toString());
  //   TextEditingController betaController =
  //       TextEditingController(text: pBeta.toString());
  //   List<bool> selected = List.generate(pollutants.length, (index) => false);
  //   int neighbors = 10;
  //   await Get.dialog(
  //     PDialog(
  //       height: 550,
  //       width: 400,
  //       // child: Container(),
  //       child: GetBuilder<DatasetController>(
  //         id: 'dialog',
  //         builder: (_) => Column(
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 const Text(
  //                   'Umap neighbors',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w500,
  //                     color: pColorPrimary,
  //                   ),
  //                 ),
  //                 PButton(
  //                     text: neighbors.toString(),
  //                     onTap: () async {
  //                       neighbors = await uiPickNumberInt(5, 100);
  //                       update(['dialog']);
  //                     })
  //               ],
  //             ),
  //             const SizedBox(height: 30),

  //             SizedBox(
  //               height: 80,
  //               width: double.infinity,
  //               child: Row(children: [
  //                 Text('Delta:'),
  //                 SizedBox(width: 70),
  //                 Expanded(
  //                   child: TextField(
  //                     controller: deltaController,
  //                   ),
  //                 ),
  //               ]),
  //             ),

  //             SizedBox(
  //               height: 80,
  //               width: double.infinity,
  //               child: Row(children: [
  //                 Text('Beta:'),
  //                 SizedBox(width: 70),
  //                 Expanded(
  //                   child: TextField(
  //                     controller: betaController,
  //                   ),
  //                 ),
  //               ]),
  //             ),

  //             //         SizedBox(
  //             //           height: 80,
  //             //           child: Row(children: [
  //             //             Text('Beta:'),
  //             //             TextField(
  //             //               controller: betaController,
  //             //             ),
  //             //           ]),
  //             //         ),
  //             //         // const SizedBox(height: 30),
  //             Spacer(),
  //             PButton(
  //               text: 'Get projection',
  //               onTap: () {
  //                 Get.back();
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //   uiShowLoader();
  //   List<dynamic> coords = await repositorySpatioTemporalSettings(
  //     neighbors: neighbors,
  //     beta: double.parse(betaController.text),
  //     delta: double.parse(deltaController.text),
  //   );

  //   for (var i = 0; i < _points!.length; i++) {
  //     _points![i].coordinates = Offset(coords[i][0], coords[i][1]);
  //   }
  //   uiHideLoader();
  //   Get.find<DashboardController>().update();
  // }

  Future<void> loadDataset(
      DatasetModel dataset,
      Granularity granularityCl,
      String granularity,
      List<String> pollutants,
      List<String> stations,
      bool shapeNorm,
      int smoothWindow) async {
    _pollutants = [];
    _stations = [];
    _dataset = dataset;
    _granularity = granularityCl;

    dynamic data = await repositoryLoadDataset(dataset.name, granularity,
        pollutants, stations, smoothWindow, shapeNorm);

    List<int> stationLabels =
        List<int>.from(data['windows_labels']['stations']);

    List<String> dateLabels =
        List<String>.from(data['windows_labels']['dates']);

    int n = stationLabels.length;
    List<WindowModel> windowModels = [];

    DateTime? beDate;
    DateTime? laDate;

    final formatter = DateFormat('EEE, d MMM yyyy HH:mm:ss');
    for (var i = 0; i < n; i++) {
      final date = formatter.parse(dateLabels[i]);
      if (beDate == null) {
        beDate = date;
        laDate = date;
      }
      if (beDate.isAfter(date)) {
        beDate = date;
      }
      if (laDate!.isBefore(date)) {
        laDate = date;
      }
      // DateTime date = DateTime.parse(dateLabels[i]);
      WindowModel window =
          WindowModel(id: i, beginDate: date, stationId: stationLabels[i]);

      windowModels.add(window);
    }

    _beginDate = beDate!;
    _endDate = laDate!;

    List<String> pollKeys = List<String>.from(data['pollutants']);
    _minValue = {};
    _maxValue = {};

    for (var i = 0; i < pollKeys.length; i++) {
      PollutantModel pollutant = PollutantModel(
        id: i,
        name: pollKeys[i],
        color: uiGetColor(i),
      );
      _pollutants.add(pollutant);

      List<dynamic> windows = List<dynamic>.from(data['windows'][pollKeys[i]]);
      List<double> windowsD = List<double>.from(windows);

      List<dynamic> windowsPrec =
          List<dynamic>.from(data['proc_windows'][pollKeys[i]]);
      List<double> windowsDPrec = List<double>.from(windows);

      _maxValue[i] = windowsD.reduce(max);
      _minValue[i] = windowsD.reduce(min);

      windows = windows.reshape([
        n,
        (windows.length / n).floor(),
      ]);

      windowsPrec = windowsPrec.reshape([
        n,
        (windowsPrec.length / n).floor(),
      ]);

      for (var i = 0; i < n; i++) {
        windowModels[i].addPollutant(
          pollutant.id,
          List<double>.from(windows[i]),
          List<double>.from(windowsPrec[i]),
        );
      }
    }

    _selectedPollutants = _pollutants;

    List<String> stationKeys = List<String>.from(data['stations'].keys);
    stationsMap = {};
    for (var i = 0; i < stationKeys.length; i++) {
      String name = data['stations'][stationKeys[i]]['name'];
      List<double> gpsCoord = uiStationCoordinates(name);
      StationModel station = StationModel(
        id: i,
        name: name,
        latitude: gpsCoord[0],
        longitude: gpsCoord[1],
      );
      stationsMap[station.id] = station;
      _stations.add(station);
    }

    for (var i = 0; i < n; i++) {
      // DateTime date = DateTime.parse(dateLabels[i]);
      WindowModel window = windowModels[i];
      // StationModel station =
      //     _stations.firstWhere((station) => station.id == window.stationId);
      StationModel station = stationsMap[window.stationId]!;
      windowsStations[window.id] = station;
    }

    List<dynamic> coords = await repositoryGetProjection(
      pollutantPositions: List.generate(pollutants.length, (index) => index),
      delta: pDelta,
      beta: pBeta,
    );

    List<dynamic> coordsOut = await repositoryGetFdaOutliers(0);

    for (var i = 0; i < _pollutants.length; i++) {
      int pollPos =
          _pollutants.indexWhere((element) => element.id == _pollutants[i].id);
      fdaOutliers[_pollutants[i].id] = await repositoryGetFdaOutliers(pollPos);
    }

    _points = [];
    for (var i = 0; i < n; i++) {
      windowModels[i].global_x = coords[i][0];
      windowModels[i].global_y = coords[i][1];
      _points!.add(IPoint(
        data: windowModels[i],
        coordinates: Offset(coords[i][0], coords[i][1]),
        localCoordinates: Offset(coordsOut[1][i], coordsOut[0][i]),
      ));
    }

    _projectedPollutant = _pollutants.first;

    await loadIaqis();
  }

  Future<void> loadIaqis() async {
    Map<String, List<int>> data = await repositoryIaqi(
        List.generate(pollutants.length, (index) => pollutants[index].name));

    if (data.isNotEmpty) {
      aqi = data['aqi'];
      iaqis = {};
      List<int> pollIds = [];
      for (var key in data.keys) {
        if (key != 'aqi') {
          PollutantModel poll =
              pollutants.firstWhere((element) => element.name == key);
          pollIds.add(poll.id);
          iaqis![poll.id] = data[key]!;
        }
      }

      for (var i = 0; i < _points!.length; i++) {
        _points![i].data.aqi = aqi![i];
        Map<int, int> iaqi = {};
        for (var key in pollIds) {
          iaqi[key] = iaqis![key]![i];
        }
        _points![i].data.iaqis = iaqi;
      }
    }
  }

  Future<void> selectPollutant(PollutantModel pollutantModel) async {
    _projectedPollutant = pollutantModel;

    int pollPos =
        _pollutants.indexWhere((element) => element.id == pollutantModel.id);
    List<dynamic> coordsOut = await repositoryGetFdaOutliers(pollPos);

    for (var i = 0; i < _points!.length; i++) {
      _points![i].localCoordinates = Offset(coordsOut[1][i], coordsOut[0][i]);
    }
  }

  void gatherDataFromWindow(WindowModel window) {
    int selectedStation = window.stationId;
    selectedWindow = window;
    List<WindowModel> windows = [];

    for (var i = 0; i < _points!.length; i++) {
      IPoint point = _points![i];
      if (point.data.stationId == selectedStation) {
        windows.add(point.data);
      }
    }

    selectedStationWindows = windows;
  }

  List<IPoint> gatherIpointsFromStation(int stationId) {
    int selectedStation = stationId;
    List<IPoint> points = [];

    for (var i = 0; i < _points!.length; i++) {
      IPoint point = _points![i];
      if (point.data.stationId == selectedStation) {
        points.add(point);
      }
    }
    return points;
  }

  void clusterByStation() {
    _resetClusters();
    _selectedStations = nonEmptyStations;

    List<IPoint> points = _points!;
    for (var i = 0; i < _selectedStations.length; i++) {
      _clusters[_selectedStations[i].identifier] = [];
    }

    for (var i = 0; i < points.length; i++) {
      IPoint point = points[i];
      String clusterId = stationsMap[point.data.stationId]!.identifier;
      point.cluster = clusterId;
      _clusters[clusterId]!.add(point);
    }

    _createClusterColors();
  }

  void clusterByMonth() {
    _resetClusters();
    List<IPoint> points = _points!;
    Map<int, String> months = {
      1: 'January',
      2: 'February',
      3: 'March',
      4: 'April',
      5: 'May',
      6: 'June',
      7: 'July',
      8: 'August',
      9: 'September',
      10: 'October',
      11: 'November',
      12: 'December',
    };
    for (var i = 1; i <= 12; i++) {
      _clusters[months[i]!] = [];
    }

    for (var i = 0; i < points.length; i++) {
      var point = points[i];
      String clusterId = months[point.data.beginDate.month]!;
      point.cluster = clusterId;
      _clusters[clusterId]!.add(point);
    }

    //  * Adding colors
    List<Color> colors;
    colors = uiRangeColor(clusterIds.length);
    for (var i = 0; i < clusterIds.length; i++) {
      _clusterColors[clusterIds[i]] = colors[i];
    }
  }

  Future<void> kmeansClustering() async {
    _resetClusters();
    List<IPoint> points = _points!;

    int nClusters = await uiPickNumberInt(2, 20);
    List<int> classes = await repositoryClustering(nClusters);

    for (var i = 0; i < nClusters; i++) {
      _clusters[i.toString()] = [];
    }

    for (var i = 0; i < points.length; i++) {
      var point = points[i];
      String clusterId = classes[i].toString();
      point.cluster = clusterId;
      _clusters[clusterId]!.add(point);
    }

    _createClusterColors();
  }

  void clearClusters() {
    _resetClusters();

    // This line should not be here [Restore default view]
    Get.find<DashboardController>().ts_visualization = 0;

    for (var i = 0; i < _points!.length; i++) {
      _points![i].cluster = null;
    }
  }

  void clusterByYear() {
    _resetClusters();

    List<IPoint> points = _points!;
    List<int> years = List.generate(_endDate.year - _beginDate.year + 1,
        (index) => _beginDate.year + index);

    for (var i = 0; i < years.length; i++) {
      _clusters[years[i].toString()] = [];
    }

    for (var i = 0; i < points.length; i++) {
      var point = points[i];
      String clusterId = point.data.beginDate.year.toString();
      point.cluster = clusterId;
      _clusters[clusterId]!.add(point);
    }

    //  * Adding colors
    List<Color> colors;
    colors = uiRangeColor(clusterIds.length);
    for (var i = 0; i < clusterIds.length; i++) {
      _clusterColors[clusterIds[i]] = colors[i];
    }
  }

  void clusterByDay() {
    _resetClusters();
    List<IPoint> points = _points!;
    Map<int, String> days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    for (var i = 1; i <= 7; i++) {
      _clusters[days[i]!] = [];
    }

    for (var i = 0; i < points.length; i++) {
      var point = points[i];
      String clusterId = days[point.data.beginDate.weekday]!;
      point.cluster = clusterId;
      _clusters[clusterId]!.add(point);
    }

    _createClusterColors();
  }

  void createClusterFromSelection() {
    int clusterPos = _clusters.length;
    String clusterId = clusterPos.toString();

    List<IPoint> selectedP = [];
    for (var i = 0; i < _points!.length; i++) {
      if (_points![i].selected) {
        selectedP.add(_points![i]);
        _points![i].cluster = clusterId;
      }
    }
    _clusters[clusterId] = selectedP;
    Color color = uiGetColor(clusterPos);
    _clusterColors[clusterId] = color;

    update();
  }

  void _resetClusters() {
    _clusters = {};
    _clusterColors = {};
    contFeatMap = null;
  }

  void _createClusterColors() {
    _clusterColors = {};

    for (var i = 0; i < clusterIds.length; i++) {
      _clusterColors[clusterIds[i]] = uiGetColor(i);
    }
  }

  Future<void> getContrastiveFeatures() async {
    if (clusterIds.length == 0 || clusterIds.length == 1) {
      Get.snackbar('System', 'Make at least two clusters');
      return;
    }
    // print();
    if (!areAllClustered()) {
      createNonClusterCluster();
    }

    List<int> labels = List.generate(_points!.length, (index) => 0);
    Map<String, int> clustMap = {};
    for (var i = 0; i < clusterIds.length; i++) {
      clustMap[clusterIds[i]] = i;
    }

    for (var i = 0; i < _points!.length; i++) {
      int? pclass = clustMap[_points![i].cluster];
      labels[i] = pclass ?? -1;
    }

    contFeatMap = await repositoryContrastiveFeatures(labels);
    contrastiveFeatures = [];
    for (int i = 0; i < contFeatMap!.keys.length; i++) {
      contrastiveFeatures!.add(contFeatMap![contFeatMap!.keys.toList()[i]]!);
    }
  }

  bool areAllClustered() {
    for (var i = 0; i < _points!.length; i++) {
      if (_points![i].cluster == null) {
        return false;
      }
    }
    return true;
  }

  void createNonClusterCluster() {
    int clusterPos = _clusters.length;
    String clusterId = clusterPos.toString();

    List<IPoint> selectedP = [];
    for (var i = 0; i < _points!.length; i++) {
      if (_points![i].cluster == null) {
        selectedP.add(_points![i]);
        _points![i].cluster = clusterId;
      }
    }
    _clusters[clusterId] = selectedP;
    Color color = uiGetColor(clusterPos);
    _clusterColors[clusterId] = color;

    update();
  }

  List<List<double>>? contrastiveFeatures;
  // List<List<double>>? contrastiveFeatures;

  DateTime? _minYear;
  DateTime? _maxYear;
  DateTime? _minMonth;
  DateTime? _maxMonth;
  DatasetModel? _dataset;
  List<DatasetModel> _datasets = [];
  late List<PollutantModel> _pollutants;
  late List<StationModel> _stations;
  List<IPoint>? _points;
  late DateTime _beginDate;
  late DateTime _endDate;
  late Granularity _granularity;
  Map<int, List<WindowModel>> _windows = {};
  List<WindowModel> _allWindows = [];
  Map<String, List<IPoint>> _clusters = {};
  Map<String, Color> _clusterColors = {};

  List<PollutantModel> _selectedPollutants = [];
  List<StationModel> _selectedStations = [];

  List<WindowModel>? selectedStationWindows;
  WindowModel? selectedWindow;

  late PollutantModel _projectedPollutant;

  Map<int, StationModel> windowsStations = {};
  late List<List<double>> mainProjection;

  Map<int, List<dynamic>> fdaOutliers = {};

  late Map<int, double> _minValue;
  late Map<int, double> _maxValue;
  Map<int, List<double>>? contFeatMap;
  Map<int, StationModel> stationsMap = {};
  Map<int, List<int>>? iaqis;
  List<int>? aqi;
}

enum Granularity {
  annual,
  monthly,
  daily,
}
