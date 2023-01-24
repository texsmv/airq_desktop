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
              image: NetworkImage(
                'https://images.wallpapersden.com/image/download/cool-landscape-night-minimal-art_bGxna2aUmZqaraWkpJRobWllrWdma2U.jpg',
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
              child: Row(children: [
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
                      ActionButton(
                        icon: 'assets/icons/clustering_icon.png',
                        selected: false,
                        onTap: () async {
                          await Get.dialog(PDialog(
                              child: Column(
                            children: [
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
                                  text: 'Automatic',
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
                        },
                      ),
                      ActionButton(
                        icon: 'assets/icons/statistics_icon.png',
                        selected: false,
                        onTap: () {
                          controller.selectionCorrelationMatrix();
                        },
                      ),
                    ],
                  ),
                ),
                const Expanded(child: DashView()),
              ]),
            ),
          ),
        ),
      ),
    );
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      'https://images.alphacoders.com/238/238683.jpg'))),
          child: Row(
            children: [
              // SideBar(
              //   tabs: [
              //     ViewTab(
              //       icon: Icons.ac_unit_outlined,
              //       onTap: () {
              //         controller.pageIndex = 0;
              //       },
              //       text: controller.dataset.name,
              //       // text: 'DatasetName',
              //       options: dashOptions(),
              //     ),
              //     // ViewTab(
              //     //   icon: Icons.sd_card,
              //     //   onTap: () {
              //     //     controller.pageIndex = 1;
              //     //   },
              //     //   text: "Summary",
              //     //   options: summaryOptions(),
              //     // ),
              //   ],
              //   selectedTab: 0,
              // ),
              Expanded(
                child: Container(
                  color: pColorScaffold,
                  child: DashView(),
                  // child: Obx(
                  //   () => IndexedStack(
                  //     index: controller.pageIndex,
                  //     children: [
                  //       GetBuilder<DatasetController>(builder: (_) {
                  //         return DashView();
                  //       }),
                  //       // SummaryView(),
                  //     ],
                  //   ),
                  // ),
                ),
              )
            ],
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
      // OutlinedButton(
      //   onPressed: controller.clusterByWeekDay,
      //   child: const Text('WeekDay'),
      // ),
    ];
  }

  // List<Widget> summaryOptions() {
  //   SummaryController summaryController = Get.find<SummaryController>();
  //   DatasetController datasetController = Get.find<DatasetController>();
  //   return [
  //     GetBuilder<DatasetController>(
  //       builder: (_) => Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           const Text(
  //             'Granularity',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: pColorPrimary,
  //             ),
  //           ),
  //           Text(
  //             datasetController.granularity == Granularity.annual
  //                 ? 'Annual'
  //                 : 'Monthly',
  //           ),
  //         ],
  //       ),
  //     ),
  //     GetBuilder<DatasetController>(
  //       builder: (_) => Switch(
  //         value: datasetController.granularity == Granularity.annual,
  //         onChanged: (value) {
  //           if (value) {
  //             summaryController.updateGranularity(Granularity.annual);
  //             summaryController.computeIntersection();
  //           } else {
  //             summaryController.updateGranularity(Granularity.monthly);
  //             summaryController.computeIntersection();
  //           }
  //         },
  //       ),
  //     ),
  //     // ...List.generate(
  //     //   summaryController.pollutants.length,
  //     //   (index) => GetBuilder<SummaryController>(
  //     //     builder: (_) => RawMaterialButton(
  //     //       fillColor: summaryController
  //     //               .isPollutantSelected(summaryController.pollutants[index].id)
  //     //           ? pColorAccent
  //     //           : const Color.fromRGBO(240, 240, 240, 1),
  //     //       onPressed: () => summaryController
  //     //           .togglePollutant(summaryController.pollutants[index].id),
  //     //       child: Text(
  //     //         summaryController.pollutants[index].name,
  //     //         style: const TextStyle(
  //     //           color: Colors.white,
  //     //         ),
  //     //       ),
  //     //     ),
  //     //   ),
  //     // ),
  //     PButton(
  //       onTap: () => summaryController.getWindows(),
  //       text: 'Get windows',
  //       light: false,
  //     ),
  //     PButton(
  //       onTap: () => summaryController.toggleAllStations(),
  //       text: 'Toogle All',
  //       light: false,
  //     ),
  //   ];
  // }
}
