import 'dart:collection';

import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/visualizations/correlation_matrix.dart';
import 'package:airq_ui/app/widgets/common/pdialog.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_controller.dart';
import 'package:airq_ui/app/widgets/pcard.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/dataset_model.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:airq_ui/models/station_model.dart';
import 'package:airq_ui/models/window_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  List<int> get years => datasetController.years;
  double xMaxValue = 1;
  double xMinValue = 0;
  double get yMaxValue => datasetController.maxSmoothedValue;
  double get yMinValue => datasetController.minSmoothedValue;
  // double get yMagnitudMaxValue => datasetController.windowsMagnitudMaxValue;
  // double get yMagnitudMinValue => datasetController.windowsMagnitudMinValue;
  double get xMinValueSeries => 1;
  // double get xMaxValueSeries => granularity == Granularity.monthly ? 30 : 365;
  double get xMaxValueSeries {
    if (granularity == Granularity.monthly) {
      return 30;
    } else if (granularity == Granularity.annual) {
      return 365;
    } else {
      return 25;
    }
  }

  List<StationModel> get stations => datasetController.selectedStations;
  List<IPoint>? get globalPoints => datasetController.globalPoints;
  List<WindowModel> get windows => datasetController.allWindows;
  List<IPoint> get ipoints => datasetController.globalPoints!;
  PollutantModel get projectedPollutant => datasetController.projectedPollutant;
  Granularity get granularity => datasetController.granularity;
  List<PollutantModel> get selectedPollutants =>
      datasetController.selectedPollutants;
  List<PollutantModel> get pollutants => datasetController.pollutants;
  List<String> get clusterIds => datasetController.clusterIds..sort();
  Map<String, Color> get clusterColors => datasetController.clusterColors;

  int get pageIndex => _pageIndex.value;
  set pageIndex(value) {
    _pageIndex.value = value;
    update();
  }

  DatasetModel get dataset => _datasetController.dataset;

  final DatasetController _datasetController = Get.find();
  final RxInt _pageIndex = RxInt(0);
  IProjectionController projectionController =
      Get.put(IProjectionController(mode: 0), tag: 'global');
  IProjectionController localProjectionController =
      Get.put(IProjectionController(mode: 1), tag: 'local');
  IProjectionController filterProjectionController =
      Get.put(IProjectionController(mode: 2), tag: 'filter');
  IProjectionController outliersProjectionController =
      Get.put(IProjectionController(mode: 3), tag: 'outlier');

  @override
  void onReady() {
    pageIndex = 1;

    if (granularity == Granularity.daily) {
      fillDays(selectedPoints);
      fillAllDays();
      fillMonths(selectedPoints);
      fillAllMonths();
    }
    if (granularity == Granularity.monthly) {
      // fillDays(selectedPoints);
      // fillAllDays();
      fillMonths(selectedPoints);
      fillAllMonths();
    }
    fillYears(selectedPoints);
    fillAllYears();
    fillStations(selectedPoints);
    fillAllStations();
    super.onReady();
  }

  Future<void> selectionCorrelationMatrix() async {
    if (selectedPoints.isEmpty) {
      return;
    }

    Map<String, List<dynamic>> map =
        await datasetController.getCorrelationMatrix(selectedPoints);

    List<dynamic> matrix = map['corrMatrix']!;
    List<double> minv = List<double>.from(map['minv']!);
    List<double> maxv = List<double>.from(map['maxv']!);
    List<double> meanv = List<double>.from(map['meanv']!);
    List<double> stdv = List<double>.from(map['stdv']!);

    List<PollutantModel> pollutants = datasetController.pollutants;

    Get.dialog(
      PDialog(
        height: 1000,
        width: 900,
        child: PCard(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: CorrelationMatrix(
                    matrix: matrix,
                    names: List.generate(
                      pollutants.length,
                      (index) => pollutants[index].name,
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                width: double.infinity,
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      child: Column(
                        children: const [
                          Text('Variable'),
                          Text('Mean'),
                          Text('Std'),
                          Text('Min'),
                          Text('Max'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pollutants.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            child: Column(
                              children: [
                                Text(pollutants[index].name),
                                Text('${meanv[index].toStringAsFixed(3)}'),
                                Text('${stdv[index].toStringAsFixed(3)}'),
                                Text('${minv[index].toStringAsFixed(3)}'),
                                Text('${maxv[index].toStringAsFixed(3)}'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectPollutant(String name) async {
    uiShowLoader();
    PollutantModel pollutant =
        selectedPollutants.firstWhere((element) => element.name == name);
    await datasetController.selectPollutant(pollutant);
    uiHideLoader();
    update();
  }

  void clusterByYear() {
    datasetController.clusterByYear();
    update();
  }

  void clusterByMonth() {
    datasetController.clusterByMonth();
    update();
  }

  void clusterByStation() {
    datasetController.clusterByStation();
    update();
  }

  void clusterByWeekDay() {
    datasetController.clusterByDay();
    update();
  }

  void clusterByOutlier() {
    datasetController.clusterByOutlier();
    update();
  }

  void clearClusters() {
    datasetController.clearClusters();

    update();
  }

  void yearRangeSelection(int begin, int end) {
    for (var i = 0; i < ipoints.length; i++) {
      ipoints[i].selected = false;
    }
    List<IPoint> selection = getSelectedYearRange(begin, end);
    for (var i = 0; i < selection.length; i++) {
      selection[i].selected = true;
    }
    onPointsSelected(selection);
  }

  void monthRangeSelection(int begin, int end) {
    for (var i = 0; i < ipoints.length; i++) {
      ipoints[i].selected = false;
    }
    List<IPoint> selection = getSelectedMonthRange(begin, end);
    for (var i = 0; i < selection.length; i++) {
      selection[i].selected = true;
    }
    onPointsSelected(selection);
  }

  void dayRangeSelection(int begin, int end) {
    for (var i = 0; i < ipoints.length; i++) {
      ipoints[i].selected = false;
    }
    List<IPoint> selection = getSelectedDayRange(begin, end);
    for (var i = 0; i < selection.length; i++) {
      selection[i].selected = true;
    }
    onPointsSelected(selection);
  }

  void onPointsSelected(List<IPoint> newSelectedPoints) {
    selectedPoints = newSelectedPoints;
    if (granularity == Granularity.daily) {
      fillDays(selectedPoints);
      fillAllDays();
      fillMonths(selectedPoints);
      fillAllMonths();
    }
    if (granularity == Granularity.monthly) {
      fillMonths(selectedPoints);
      fillAllMonths();
    }
    fillYears(selectedPoints);
    fillStations(selectedPoints);
    fillAllStations();
    fillAllYears();

    if (selectedPoints.isNotEmpty) {
      datasetController.gatherDataFromWindow(selectedPoints.first.data);
    }
    update();
  }

  void onPointPicked(IPoint point) {
    datasetController.selectedWindow = point.data;
    datasetController.gatherDataFromWindow(datasetController.selectedWindow!);
    update();
  }

  List<IPoint> getSelectedDayRange(int begin, int end) {
    dayBegin = begin;
    dayEnd = end;
    return filterByCharts();
  }

  List<IPoint> getSelectedMonthRange(int begin, int end) {
    monthBegin = begin;
    monthEnd = end;
    return filterByCharts();
  }

  List<IPoint> getSelectedYearRange(int begin, int end) {
    yearBegin = begin;
    yearEnd = end;
    return filterByCharts();
  }

  void selectStation(StationModel station) {
    if (selectedStations[station.id] == null) {
      selectedStations[station.id] = station;
    } else {
      selectedStations.remove(station.id);
    }
    // if (selectedStation != null && selectedStation!.id == station.id) {
    //   selectedStation = null;
    // } else {
    //   selectedStation = station;
    // }

    for (var i = 0; i < ipoints.length; i++) {
      ipoints[i].selected = false;
      if (selectedStations[ipoints[i].data.stationId] != null) {
        ipoints[i].selected = true;
      }
    }

    List<IPoint> selection = filterByCharts();

    onPointsSelected(selection);
  }

  Future<void> contrastiveFeatures() async {
    await datasetController.getContrastiveFeatures();
    update();
  }

  Future<void> kmeansClustering() async {
    await datasetController.kmeansClustering();
    update();
  }

  Future<void> dbscanClustering() async {
    await datasetController.dbscanClustering();
    update();
  }

  void selectCluster(String clusterId) {
    for (var i = 0; i < ipoints.length; i++) {
      ipoints[i].selected = false;
    }
    List<IPoint> selection = datasetController.clusters[clusterId]!;

    for (var i = 0; i < selection.length; i++) {
      selection[i].selected = true;
    }
    onPointsSelected(selection);
  }

  List<IPoint> filterByCharts() {
    int firstYear = datasetController.years.first;

    List<IPoint> selection = [];
    for (var i = 0; i < ipoints.length; i++) {
      WindowModel window = ipoints[i].data as WindowModel;
      int dayIndex = window.beginDate.weekday - 1;
      int monthIndex = window.beginDate.month - 1;
      int yearIndex = window.beginDate.year - firstYear;

      // TODO check this change
      bool withinDayRange = dayIndex >= dayBegin && dayIndex <= dayEnd;
      bool withinMonthRange =
          monthIndex >= monthBegin && monthIndex <= monthEnd;
      bool withinYearRange = yearIndex >= yearBegin && yearIndex <= yearEnd;

      late bool withinStations;
      if (selectedStations.isEmpty) {
        withinStations = true;
      } else {
        withinStations = selectedStations[window.stationId] != null;
      }

      if (withinDayRange &&
          withinMonthRange &&
          withinYearRange & withinStations) {
        selection.add(ipoints[i]);
        ipoints[i].withinFilter = true;
      } else {
        ipoints[i].withinFilter = false;
      }
    }
    return selection;
  }

  void fillDays(List<IPoint> points) {
    dayCounts = List.generate(7, (index) => 0);

    for (var i = 0; i < points.length; i++) {
      WindowModel window = points[i].data as WindowModel;
      dayCounts[window.beginDate.weekday - 1]++;
    }
  }

  void fillAllDays() {
    allDaysCounts = List.generate(7, (index) => 0);

    if (haveClusters) {
      for (String id in clusterIds) {
        clustersDayCounts[id] = List.generate(7, (index) => 0);
      }
    }

    for (var i = 0; i < ipoints.length; i++) {
      WindowModel window = ipoints[i].data as WindowModel;
      allDaysCounts[window.beginDate.weekday - 1]++;
      // if (haveClusters) {
      if (ipoints[i].cluster != null) {
        clustersDayCounts[ipoints[i].cluster!]![window.beginDate.weekday - 1]++;
      }
    }
  }

  void fillStations(List<IPoint> points) {
    stationCounts = List.generate(stations.length, (index) => 0);
    for (var i = 0; i < points.length; i++) {
      WindowModel window = points[i].data as WindowModel;
      int stationId = window.stationId;
      for (var i = 0; i < stations.length; i++) {
        if (stationId == stations[i].id) {
          stationCounts[i]++;
          break;
        }
      }
    }
    // print('stationCounts: $stationCounts');
  }

  void fillAllStations() {
    allStationCounts = List.generate(stations.length, (index) => 0);
    for (var i = 0; i < ipoints.length; i++) {
      WindowModel window = ipoints[i].data as WindowModel;

      for (var i = 0; i < stations.length; i++) {
        if (window.stationId == stations[i].id) {
          allStationCounts[i]++;
          break;
        }
      }
    }
    // print('stationCounts: $stationCounts');
  }

  void fillMonths(List<IPoint> points) {
    monthCounts = List.generate(12, (index) => 0);

    for (var i = 0; i < points.length; i++) {
      WindowModel window = points[i].data as WindowModel;
      monthCounts[window.beginDate.month - 1]++;
    }
    // print(clustersMonthCounts);
    // print('monthCounts: $monthCounts');
  }

  void fillAllMonths() {
    allMonthsCounts = List.generate(12, (index) => 0);

    if (haveClusters) {
      for (String id in clusterIds) {
        clustersMonthCounts[id] = List.generate(12, (index) => 0);
      }
    }
    for (var i = 0; i < ipoints.length; i++) {
      WindowModel window = ipoints[i].data as WindowModel;
      allMonthsCounts[window.beginDate.month - 1]++;
      // if (haveClusters) {
      if (ipoints[i].cluster != null) {
        clustersMonthCounts[ipoints[i].cluster!]![window.beginDate.month - 1]++;
      }
    }
    // print('allMonthsCounts: $allMonthsCounts');
  }

  void fillAllYears() {
    int firstYear = datasetController.years.first;
    allYearsCounts =
        List.generate(datasetController.years.length, (index) => 0);

    if (haveClusters) {
      for (String id in clusterIds) {
        clustersYearsCounts[id] =
            List.generate(datasetController.years.length, (index) => 0);
      }
    }
    for (var i = 0; i < ipoints.length; i++) {
      WindowModel window = ipoints[i].data as WindowModel;
      allYearsCounts[window.beginDate.year - firstYear]++;

      // if (haveClusters) {
      if (ipoints[i].cluster != null) {
        clustersYearsCounts[ipoints[i].cluster!]![
            window.beginDate.year - firstYear]++;
      }
    }
    // print('allYearCounts: $allYearsCounts');
  }

  void fillYears(List<IPoint> points) {
    yearEnd = datasetController.years.length - 1;
    int firstYear = datasetController.years.first;

    yearCounts = List.generate(datasetController.years.length, (index) => 0);

    for (var i = 0; i < points.length; i++) {
      WindowModel window = points[i].data as WindowModel;
      yearCounts[window.beginDate.year - firstYear]++;
    }
  }

  void manualCluster() {
    datasetController.createClusterFromSelection();
    update();
  }

  // void updateData

  // Future<void> selectPollutant(String name) async {
  //   uiShowLoader();
  //   PollutantModel pollutant =
  //       selectedPollutants.firstWhere((element) => element.name == name);
  //   datasetController.selectPollutant(pollutant);
  //   await datasetController.computeIaqi(pollutant);
  //   uiHideLoader();
  //   update();
  // }

  DatasetController datasetController = Get.find();

  List<int> dayCounts = List.generate(7, (index) => 0);
  List<int> monthCounts = List.generate(12, (index) => 0);
  List<int> yearCounts = [];
  List<int> stationCounts = [];

  List<int> allDaysCounts = [];
  List<int> allMonthsCounts = [];
  List<int> allYearsCounts = [];
  List<int> allStationCounts = [];

  List<IPoint> selectedPoints = [];
  RxBool isReseted = false.obs;

  int dayBegin = 0;
  int dayEnd = 6;

  int monthBegin = 0;
  int monthEnd = 11;

  int yearBegin = 0;
  late int yearEnd;

  IPoint? infoPoint;

  int ts_visualization = 0;

  // StationModel? selectedStation;

  bool map_cluster_mode = false;
  bool map_selection_mode = true;
  bool showShape = false;
  RxBool pickMode = false.obs;
  RxBool binsPercentage = false.obs;
  RxBool binsClusterMode = false.obs;
  Map<String, List<int>> clustersDayCounts = {};
  Map<String, List<int>> clustersMonthCounts = {};
  Map<String, List<int>> clustersYearsCounts = {};

  bool get haveClusters => datasetController.clusterIds.isNotEmpty;
  List<String> get clurtersIds => datasetController.clusterIds;

  HashMap<int, StationModel> selectedStations = HashMap<int, StationModel>();
}
