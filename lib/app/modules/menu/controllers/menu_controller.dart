import 'dart:developer';

import 'package:airq_ui/app/routes/app_pages.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/common/light_button.dart';
import 'package:airq_ui/app/widgets/common/pdialog.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/dataset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../widgets/common/pbutton.dart';

class MyMenuController extends GetxController {
  Map<int, List<String>> selectedPollutants = {};
  Map<int, List<String>> selectedStations = {};
  List<DatasetModel> get datasets => datasetController.datasets;

  bool isPollutantSelected(int datasetId, String pollutant) {
    List<String>? datasetPoll = selectedPollutants[datasetId];
    if (datasetPoll == null || datasetPoll.isEmpty) {
      return false;
    }

    return datasetPoll.contains(pollutant);
  }

  void tapPollutant(int datasetId, String pollutant) {
    List<String>? datasetPoll = selectedPollutants[datasetId];
    if (datasetPoll == null) {
      selectedPollutants[datasetId] = [];
    }

    if (selectedPollutants[datasetId]!.contains(pollutant)) {
      selectedPollutants[datasetId]!.remove(pollutant);
    } else {
      selectedPollutants[datasetId]!.add(pollutant);
    }
    update();
  }

  bool isStationSelected(int datasetId, String station) {
    List<String>? datasetStation = selectedStations[datasetId];
    if (datasetStation == null || datasetStation.isEmpty) {
      return false;
    }

    return datasetStation.contains(station);
  }

  void tapStation(int datasetId, String station) {
    List<String>? datasetStation = selectedStations[datasetId];
    if (datasetStation == null) {
      selectedStations[datasetId] = [];
    }

    if (selectedStations[datasetId]!.contains(station)) {
      selectedStations[datasetId]!.remove(station);
    } else {
      selectedStations[datasetId]!.add(station);
    }
    update();
  }

  Future<void> openDataset(DatasetModel dataset) async {
    List<String>? datasetPoll = selectedPollutants[dataset.id];
    if (datasetPoll == null || datasetPoll.isEmpty) {
      EasyLoading.dismiss();
      Get.snackbar('Error', 'Select at least one pollutant');
      return;
    }
    late String granularityStr;
    Granularity chosenGranularity = await chooseGranularity();
    late int maxSmoothSize;
    late int defaultSmoothSize;
    if (chosenGranularity == Granularity.annual) {
      granularityStr = 'years';
      maxSmoothSize = 350;
      defaultSmoothSize = 40;
    } else if (chosenGranularity == Granularity.monthly) {
      granularityStr = 'months';
      maxSmoothSize = 20;
      defaultSmoothSize = 12;
    } else if (chosenGranularity == Granularity.daily) {
      granularityStr = 'daily';
      maxSmoothSize = 20;
      defaultSmoothSize = 9;
    }

    int smoothWindow = await uiPickNumberInt(3, maxSmoothSize,
        defaultValue: defaultSmoothSize);

    EasyLoading.show(status: 'Loading...');

    List<String>? sStations = selectedStations[dataset.id];
    if (sStations == null) {
      sStations = dataset.allStations;
    } else if (sStations.isEmpty) {
      sStations = dataset.allStations;
    }
    // await Duration(seconds: 5);
    bool done = await datasetController.loadDataset(
        dataset,
        chosenGranularity,
        granularityStr,
        selectedPollutants[dataset.id]!,
        sStations,
        shapeNormalization,
        smoothWindow);
    EasyLoading.dismiss();

    if (done) {
      print('Routing now!!!');
      Get.toNamed(Routes.DASHBOARD);
      print('Routing done!!!');
    }
  }

  Future<Granularity> chooseGranularity() async {
    return await Get.dialog(
      PDialog(
        child: SizedBox(
          height: 300,
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PButton(
                  onTap: () {
                    Get.back(result: Granularity.daily);
                  },
                  text: 'Daily'),
              PButton(
                  onTap: () {
                    Get.back(result: Granularity.monthly);
                  },
                  text: 'Monthly'),
              PButton(
                  onTap: () {
                    Get.back(result: Granularity.annual);
                  },
                  text: 'Annual'),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  final DatasetController datasetController = Get.find();
  bool shapeNormalization = false;
}
