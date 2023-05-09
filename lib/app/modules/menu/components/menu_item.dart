import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/modules/menu/controllers/menu_controller.dart';
import 'package:airq_ui/app/widgets/common/light_button.dart';
import 'package:airq_ui/models/dataset_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/common/pbutton.dart';

class MyMenuItem extends GetView<MyMenuController> {
  final DatasetModel dataset;
  const MyMenuItem({Key? key, required this.dataset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 120,
            alignment: Alignment.center,
            child: Text(
              dataset.name,
              style: const TextStyle(
                color: pTextColorPrimary,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: GetBuilder<MyMenuController>(
                builder: (_) => Wrap(
                  spacing: 8,
                  children: List.generate(
                    dataset.pollutants.length,
                    (i) => SizedBox(
                      height: 15,
                      width: 49,
                      child: !controller.isPollutantSelected(
                              dataset.id, dataset.pollutants[i])
                          ? PButton.light(
                              text: dataset.pollutants[i],
                              onTap: () {
                                controller.tapPollutant(
                                    dataset.id, dataset.pollutants[i]);
                              },
                            )
                          : PButton(
                              text: dataset.pollutants[i],
                              onTap: () {
                                controller.tapPollutant(
                                    dataset.id, dataset.pollutants[i]);
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: GetBuilder<MyMenuController>(
                builder: (_) => Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: List.generate(
                    dataset.allStations.length,
                    (i) => SizedBox(
                      height: 18,
                      width: 80,
                      child: !controller.isStationSelected(
                              dataset.id, dataset.allStations[i])
                          ? PButton.light(
                              text: dataset.allStations[i],
                              onTap: () {
                                controller.tapStation(
                                    dataset.id, dataset.allStations[i]);
                              },
                            )
                          : PButton(
                              text: dataset.allStations[i],
                              onTap: () {
                                controller.tapStation(
                                    dataset.id, dataset.allStations[i]);
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
              width: 95,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => controller.openDataset(dataset),
                    icon: Icon(
                      Icons.open_in_new,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.openDataset(dataset),
                    icon: Icon(Icons.download),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
