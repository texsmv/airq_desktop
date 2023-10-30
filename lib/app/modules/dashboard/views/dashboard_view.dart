import 'dart:ui';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/constants/constants.dart';
import 'package:airq_ui/app/modules/dashboard/components/outliers_chart.dart';
import 'package:airq_ui/app/modules/dashboard/components/pbar.dart';
import 'package:airq_ui/app/modules/dashboard/views/dash_view.dart';
import 'package:airq_ui/app/widgets/common/light_button.dart';
import 'package:airq_ui/app/widgets/common/pdialog.dart';
import 'package:airq_ui/app/widgets/side_bar.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../widgets/common/pbutton.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  DatasetController get datasetController => Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/wallpaper.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
              ),
              child: GetBuilder<DatasetController>(builder: (c) {
                return Row(children: [
                  Obx(
                    () => PBar(
                      actions: [
                        ActionButton(
                          icon: 'assets/icons/projection_icon.png',
                          selected: false,
                          onTap: () {
                            datasetController.projectSeries();
                          },
                        ),
                        // ActionButton(
                        //   icon: 'assets/icons/projection_icon.png',
                        //   selected: false,
                        //   onTap: () {
                        //     datasetController.changeSpatioTemporalSettings();
                        //   },
                        // ),
                        ActionButton(
                          icon: 'assets/icons/clustering_icon.png',
                          selected: false,
                          onTap: () async {
                            await Get.dialog(PDialog(
                                height: 400,
                                child: Column(
                                  children: [
                                    Visibility(
                                      visible: controller.granularity ==
                                          Granularity.daily,
                                      child: SizedBox(
                                        height: 25,
                                        child: PButton(
                                          onTap: () {
                                            controller.clusterByWeekDay();
                                            Get.back();
                                          },
                                          text: 'Day',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Visibility(
                                      visible: controller.granularity !=
                                          Granularity.annual,
                                      child: SizedBox(
                                        height: 25,
                                        child: PButton(
                                          onTap: () {
                                            controller.clusterByMonth();
                                            Get.back();
                                          },
                                          text: 'Month',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 25,
                                      child: PButton(
                                          onTap: () {
                                            controller.clusterByYear();
                                            Get.back();
                                          },
                                          text: 'Year'),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 25,
                                      child: PButton(
                                        onTap: () {
                                          controller.clusterByStation();
                                          Get.back();
                                        },
                                        text: 'Station',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 25,
                                      child: PButton(
                                        onTap: () async {
                                          await controller.kmeansClustering();
                                          Get.back();
                                        },
                                        text: 'Kmeans',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 25,
                                      child: PButton(
                                        onTap: () async {
                                          await controller.dbscanClustering();
                                          Get.back();
                                        },
                                        text: 'DBSCAN',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 25,
                                      child: PButton(
                                        onTap: () {
                                          controller.clusterByOutlier();
                                          Get.back();
                                        },
                                        text: 'Outliers',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 25,
                                      child: PButton(
                                        onTap: () {
                                          controller.manualCluster();
                                          Get.back();
                                        },
                                        text: 'Manual',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 25,
                                      child: PButton(
                                        fillColor: pColorError,
                                        onTap: () {
                                          controller.clearClusters();
                                          Get.back();
                                        },
                                        text: 'Clear all',
                                      ),
                                    ),
                                  ],
                                )));
                          },
                        ),
                        ActionButton(
                          icon: 'assets/icons/selection_icon.png',
                          selected: controller.pickMode.value,
                          onTap: () {
                            controller.pickMode.value =
                                !controller.pickMode.value;
                            controller.projectionController.clearSelection();
                            controller.localProjectionController
                                .clearSelection();
                            controller.filterProjectionController
                                .clearSelection();
                            controller.outliersProjectionController
                                .clearSelection();
                          },
                        ),
                        ActionButton(
                          icon: 'assets/icons/statistics.png',
                          selected: false,
                          onTap: () {
                            controller.selectionCorrelationMatrix();
                          },
                        ),
                        ActionButton(
                          icon: 'assets/icons/filter.png',
                          selected: controller.datasetController.show_filtered,
                          onTap: () {
                            controller.datasetController.show_filtered =
                                !controller.datasetController.show_filtered;
                            controller.datasetController.update();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: DashView()),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> dashOptions() {
    //   SummaryController summaryController = Get.find<SummaryController>();
    DatasetController datasetController = Get.find<DatasetController>();
    return [
      const Divider(),
      const Text(
        'Cluster by',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: pTextColorSecondary,
        ),
      ),
      Column(
        children: [
          SizedBox(
            height: 25,
            child: PButton(onTap: controller.clusterByYear, text: 'Year'),
          ),
          Visibility(
            visible: controller.granularity != Granularity.annual,
            child: SizedBox(
              height: 25,
              child: PButton(
                onTap: controller.clusterByMonth,
                text: 'Month',
              ),
            ),
          ),
          SizedBox(
            height: 25,
            child: PButton(
              onTap: controller.clusterByStation,
              text: 'Station',
            ),
          ),
          SizedBox(
            height: 25,
            child: PButton(
              onTap: controller.kmeansClustering,
              text: 'Automatic',
            ),
          ),
          SizedBox(
            height: 25,
            child: PButton(
              onTap: controller.clusterByOutlier,
              text: 'Outliers',
            ),
          ),
          SizedBox(
            height: 25,
            child: PButton(
              onTap: controller.manualCluster,
              text: 'Manual',
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 25,
            child: PButton(
              onTap: controller.clearClusters,
              text: 'Clear all',
            ),
          ),
        ],
      ),
      GetBuilder<DashboardController>(
        id: 'infoPoint',
        builder: (_) {
          return controller.infoPoint != null
              ? Container(
                  height: 300,
                  child: Column(
                    children: [
                      Text(
                          'Date: ${controller.infoPoint!.data.beginDate.toString().substring(0, 10)}'),
                      Text(
                          'Date: ${controller.infoPoint!.data.beginDate.toString().substring(0, 10)}'),
                      controller.infoPoint!.cluster != null
                          ? Text('Cluster: ${controller.infoPoint!.cluster}')
                          : SizedBox(),
                    ],
                  ),
                )
              : SizedBox();
        },
      ),
      PButton(
        onTap: () {
          controller.contrastiveFeatures();
        },
        text: 'ContrastiveFeat',
      ),
      PButton(
        onTap: () {
          controller.selectionCorrelationMatrix();
        },
        text: 'CorrelationMatrix',
      ),
      Container(
        height: 700,
        width: double.infinity,
        child: GetBuilder<DashboardController>(builder: (_) => OutliersChart()),
      ),
    ];
  }
}
