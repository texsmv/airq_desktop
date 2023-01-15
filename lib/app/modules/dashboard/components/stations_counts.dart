import 'package:airq_ui/app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../controllers/dataset_controller.dart';

import 'package:rainbow_color/rainbow_color.dart';

class StationsCounts extends GetView<DashboardController> {
  const StationsCounts({Key? key}) : super(key: key);

  DatasetController get datasetController => Get.find();

  @override
  Widget build(BuildContext context) {
    if (controller.stationCounts.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 10,
        children: List.generate(controller.stations.length, (index) {
          bool isVisible = controller.stationCounts[index] != 0;
          return GestureDetector(
            onTap: () {
              controller.selectStation(controller.stations[index]);
            },
            child: Visibility(
              visible: isVisible,
              child: Chip(
                backgroundColor: chipColor(index),
                label: Container(
                  width: 88,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.stations[index].name,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 35,
                        child: Text(
                          chipLabel(index),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color chipColor(int index) {
    if (controller.allStationCounts[index] == 0) {
      return pColorLight;
    }
    var rb = Rainbow(
      // spectrum: [const Color.fromRGBO(200, 200, 200, 0.5), pColorPrimary],
      spectrum: [const Color.fromRGBO(100, 100, 100, 0.5), pColorDark],
      rangeStart: 0,
      rangeEnd: 2 * controller.allStationCounts[index],
    );
    int modifiedValue;
    if (controller.stationCounts[index] != 0) {
      modifiedValue =
          controller.stationCounts[index] + controller.allStationCounts[index];
    } else {
      modifiedValue = controller.stationCounts[index];
    }

    return rb[modifiedValue];
  }

  String chipLabel(int index) {
    return ' ${controller.stationCounts[index]} / ${controller.allStationCounts[index]}';
  }
}
