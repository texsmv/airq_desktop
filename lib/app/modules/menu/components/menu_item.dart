import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/modules/menu/controllers/menu_controller.dart';
import 'package:airq_ui/app/widgets/common/light_button.dart';
import 'package:airq_ui/models/dataset_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/common/pbutton.dart';

class MyMenuItem extends GetView<MenuController> {
  final DatasetModel dataset;
  const MyMenuItem({Key? key, required this.dataset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                dataset.name,
                style: const TextStyle(
                  color: pTextColorPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: GetBuilder<MenuController>(
                builder: (_) => Wrap(
                  spacing: 8,
                  children: List.generate(
                    dataset.pollutants.length,
                    (i) => SizedBox(
                      height: 15,
                      width: 49,
                      child: !controller.isPollutantSelected(
                              dataset.id, dataset.pollutants[i])
                          ? PButton(
                              text: dataset.pollutants[i],
                              onTap: () {
                                controller.tapPollutant(
                                    dataset.id, dataset.pollutants[i]);
                              },
                            )
                          : PButton.light(
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
              // child: Text(
              //   dataset.pollutants
              //       .reduce((value, element) => value + ' - ' + element),
              //   style: TextStyle(fontSize: 12),
              // ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '15',
              ),
            ),
          ),
          Expanded(
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
