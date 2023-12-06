import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/station_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:rainbow_color/rainbow_color.dart';

import '../constants/colors.dart';

class StationsMap extends StatefulWidget {
  final bool clusterView;
  StationsMap({Key? key, required this.clusterView}) : super(key: key);

  @override
  State<StationsMap> createState() => _StationsMapState();
}

class _StationsMapState extends State<StationsMap> {
  DatasetController datasetController = Get.find<DatasetController>();
  DashboardController dashboardController = Get.find();

  static const String mapBoxAccessToken =
      'pk.eyJ1IjoidGV4cyIsImEiOiJjbDZiNXFkZGgxdjUzM2ptcWd4N3c5dHZwIn0.RaHsfU1JFLbQku_uNXS46A';

  static const String mapBoxStyleId = 'clcj0tcbj006a14paiqcg65xf';

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: _getCenter(),
        zoom: 6.0,
      ),
      children: [
        TileLayer(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/texs/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
          additionalOptions: {
            'mapStyleId': mapBoxStyleId,
            'accessToken': mapBoxAccessToken,
          },
        ),
        MarkerLayer(
          markers: _markers(),
        )
      ],
    );
  }

  LatLng _getCenter() {
    double lat = 0, lng = 0;
    int counter = 0;
    List<StationModel> stations = [];
    for (var i = 0; i < datasetController.stations.length; i++) {
      if (datasetController.stations[i].latitude != null) {
        counter++;
        lat += datasetController.stations[i].latitude!;
        lng += datasetController.stations[i].longitude!;
        stations.add(datasetController.stations[i]);
      }
    }
    lat = lat / counter;
    lng = lng / counter;
    // print('CORODS');
    // print(LatLng(lat, lng));
    return LatLng(lat, lng);
  }

  List<Marker> _markers() {
    List<StationModel> stations = [];
    List<LatLng?> coords = [];
    for (var i = 0; i < datasetController.stations.length; i++) {
      if (datasetController.stations[i].latitude != null) {
        // stations.add(datasetController.selectedStations[i]);
        coords.add(LatLng(datasetController.stations[i].latitude!,
            datasetController.stations[i].longitude!));
      } else {
        coords.add(null);
        // visible.add(false);
      }
      stations.add(datasetController.stations[i]);
    }
    return List.generate(stations.length, (index) {
      // print(index);
      // print(LatLng(stations[index].latitude!, stations[index].longitude!));
      return Marker(
        width: 120.0,
        height: 80.0,
        point: coords[index] != null
            ? LatLng(stations[index].latitude!, stations[index].longitude!)
            : LatLng(0, 0),
        builder: (ctx) => Visibility(
          visible: coords[index] != null,
          child: GestureDetector(
            onTap: () {
              dashboardController.selectStation(stations[index]);
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MarkerChart(
                    clusterColors: datasetController.clusterColors,
                    clusterCounts: datasetController
                        .clustersStationCounts[stations[index].id],
                    maxCount: maxStationsCount,
                    clusterView: widget.clusterView,
                    index: index,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  static const double minOpacity = 30.0;
  static const double minSize = 20.0;
  static const double maxSize = 60.0;

  int get maxStationsCount {
    List<int> counts = List.generate(dashboardController.stationCounts.length,
        (index) => dashboardController.stationCounts[index]);
    return counts.reduce(max);
  }

  String chipLabel(int index) {
    if (dashboardController.stationCounts.isEmpty) return "";
    return '${dashboardController.stationCounts[index]}';
  }
}

class MarkerChart extends StatefulWidget {
  final Map<String, Color> clusterColors;
  final Map<String, int>? clusterCounts;
  final int maxCount;
  final int index;
  final bool clusterView;
  const MarkerChart({
    super.key,
    required this.clusterColors,
    required this.clusterCounts,
    required this.maxCount,
    required this.index,
    required this.clusterView,
  });

  @override
  State<MarkerChart> createState() => _MarkerChartState();
}

class _MarkerChartState extends State<MarkerChart> {
  List<double> ratios = [];
  List<Color> colors = [];

  DatasetController datasetController = Get.find<DatasetController>();
  DashboardController dashboardController = Get.find();
  int get index => widget.index;

  double stationSizeRatio() {
    if (!widget.clusterView) {
      return dashboardController.stationCounts[index] /
          dashboardController.stationCounts.reduce(max);
      // dashboardController.stationCounts.reduce(max);
    } else {
      return 1 / 1.5;
      return dashboardController.allStationCounts[index] /
          dashboardController.allStationCounts.reduce(max);
    }
  }

  static const double minSize = 20.0;
  static const double maxSize = 60.0;
  static const double minOpacity = 30.0;
  @override
  void didUpdateWidget(covariant MarkerChart oldWidget) {
    createLists();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    createLists();
    super.initState();
  }

  void createLists() {
    if (widget.clusterCounts != null) {
      List<int> counts = [];
      ratios = [];
      colors = [];
      List<String> clusters = widget.clusterColors.keys.toList();
      for (String cluster in clusters) {
        counts.add(widget.clusterCounts![cluster]!);
        colors.add(widget.clusterColors[cluster]!);
      }

      ratios = List.generate(counts.length,
          (index) => counts[index] / counts.reduce((a, b) => a + b));
    }
  }

  double markerSize() {
    if (dashboardController.infoPoint != null) {
      if (datasetController
              .windowsStations[dashboardController.infoPoint!.data.id]!.id ==
          dashboardController.stations[index].id) {
        return (minSize + maxSize) / 2;
        ; // Dont know what is this for ....
      }
    }

    if (dashboardController.allStationCounts.isEmpty) {
      return (minSize + maxSize) / 2;
    }

    if (dashboardController.allStationCounts[index] == 0) {
      return minSize;
    }

    if (widget.maxCount == 0) {
      return minSize;
    }

    return stationSizeRatio() * (maxSize - minSize);
  }

  Color chipColor(int index) {
    return Color.fromARGB(255, 82, 128, 182);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          datasetController.stations[index].name,
          style: const TextStyle(
            color: Color.fromRGBO(240, 190, 50, 1),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: markerSize(),
          width: markerSize(),
          child: widget.clusterView
              ? CustomPaint(
                  painter: MarkerChartPainter(
                    colors: colors,
                    ratios: ratios,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: markerSize() == minSize
                        ? chipColor(index).withOpacity(0.3)
                        : chipColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      dashboardController.stationCounts[index].toString(),
                      style: TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class MarkerChartPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> ratios;
  MarkerChartPainter({required this.colors, required this.ratios});

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = 0;
    double totalAngle = 3.1415 * 2;
    for (var i = 0; i < colors.length; i++) {
      // double endDegree = startDegree + totalDegree * ratios[i];
      double sweepAngle = totalAngle * ratios[i];
      Paint paint = Paint()..color = colors[i];
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle = startAngle + sweepAngle;
    }

    // List<double> radius = [];
    // double totalRadius = size.width / 2;
    // double currRadius = 0;
    // for (var i = 0; i < colors.length; i++) {
    //   // double endDegree = startDegree + totalDegree * ratios[i];
    //   currRadius = totalRadius * ratios[i] + currRadius;
    //   radius.add(currRadius);
    // }

    // for (var i = colors.length - 1; i >= 0; i--) {
    //   Paint paint = Paint()..color = colors[i];
    //   canvas.drawCircle(Offset.zero, radius[i], paint);
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
