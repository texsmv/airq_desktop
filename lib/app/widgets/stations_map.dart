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
  StationsMap({Key? key}) : super(key: key);

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
      layers: [
        TileLayerOptions(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/texs/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
          additionalOptions: {
            'mapStyleId': mapBoxStyleId,
            'accessToken': mapBoxAccessToken,
          },
        ),
        // TileLayerOptions(
        //   wmsOptions: WMSTileLayerOptions(
        //     // Set the WMS layer's CRS too
        //     // crs: epsg3413CRS,
        //     baseUrl:
        //         'https://www.gebco.net/data_and_products/gebco_web_services/north_polar_view_wms/mapserv?',
        //     layers: ['gebco_north_polar_view'],
        //   ),
        // ),
        MarkerLayerOptions(
          markers: _markers(),
        ),
      ],
    );
  }

  LatLng _getCenter() {
    double lat = 0, lng = 0;
    int counter = 0;
    List<StationModel> stations = [];
    for (var i = 0; i < datasetController.selectedStations.length; i++) {
      if (datasetController.selectedStations[i].latitude != null) {
        counter++;
        lat += datasetController.selectedStations[i].latitude!;
        lng += datasetController.selectedStations[i].longitude!;
        stations.add(datasetController.selectedStations[i]);
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
    for (var i = 0; i < datasetController.selectedStations.length; i++) {
      if (datasetController.selectedStations[i].latitude != null) {
        // stations.add(datasetController.selectedStations[i]);
        coords.add(LatLng(datasetController.selectedStations[i].latitude!,
            datasetController.selectedStations[i].longitude!));
      } else {
        coords.add(null);
        // visible.add(false);
      }
      stations.add(datasetController.selectedStations[i]);
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
                  // Icon(
                  //   Icons.location_on_sharp,
                  //   size: 20,
                  //   color: chipColor(index),
                  // ),
                  Container(
                    height: chipSize(index),
                    width: chipSize(index),
                    decoration: BoxDecoration(
                      color: chipColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    stations[index].name,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: chipColor(index),
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    chipLabel(index),
                    style: TextStyle(
                      color: chipColor(index),
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
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

  Color chipColor(int index) {
    if (dashboardController.infoPoint != null) {
      if (datasetController
              .windowsStations[dashboardController.infoPoint!.data.id]!.id ==
          dashboardController.stations[index].id) {
        return Colors.red;
      }
    }
    if (dashboardController.allStationCounts.isEmpty) {
      return const Color.fromRGBO(200, 200, 200, minOpacity);
    }
    if (dashboardController.allStationCounts[index] == 0) {
      return Colors.transparent;
    }
    int modifiedValue;
    modifiedValue = dashboardController.stationCounts[index];
    if (maxStationsCount == 0) {
      return const Color.fromRGBO(80, 80, 80, minOpacity);
    }
    var rb = Rainbow(
      spectrum: [
        const Color.fromRGBO(80, 80, 80, minOpacity),
        Color.fromARGB(255, 82, 128, 182),
        // Colors.red,
      ],
      rangeStart: 0,
      rangeEnd: maxStationsCount,
    );
    // if (dashboardController.stationCounts[index] != 0) {
    //   modifiedValue = dashboardController.stationCounts[index] +
    //       dashboardController.allStationCounts[index];
    // } else {
    //   modifiedValue = dashboardController.stationCounts[index];
    // }
    // print(modifiedValue);
    return rb[modifiedValue];
  }

  double chipSize(int index) {
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
    int modifiedValue;
    modifiedValue = dashboardController.stationCounts[index];
    if (maxStationsCount == 0) {
      return minSize;
    }

    // if (dashboardController.stationCounts[index] != 0) {
    //   modifiedValue = dashboardController.stationCounts[index] +
    //       dashboardController.allStationCounts[index];
    // } else {
    //   modifiedValue = dashboardController.stationCounts[index];
    // }
    // print(modifiedValue);
    return (modifiedValue / maxStationsCount) * (maxSize - minSize);
  }

  // Color chipColor(int index) {
  //   // In case a station doesn't have any count
  //   if (dashboardController.allStationCounts[index] == 0) {
  //     return Colors.transparent;
  //   }
  //   var rb = Rainbow(
  //     spectrum: [const Color.fromRGBO(220, 220, 220, 1), pColorPrimary],
  //     rangeStart: 0,
  //     rangeEnd: dashboardController.allStationCounts[index],
  //   );

  //   return rb[dashboardController.stationCounts[index]];
  // }

  String chipLabel(int index) {
    if (dashboardController.stationCounts.isEmpty) return "";
    return '${dashboardController.stationCounts[index]}';
  }
}
