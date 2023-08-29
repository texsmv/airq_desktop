import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/constants/constants.dart';
import 'package:airq_ui/app/modules/dashboard/components/aqi_chart.dart';
import 'package:airq_ui/app/modules/dashboard/components/cfeatures_chart.dart';
import 'package:airq_ui/app/modules/dashboard/components/outliers_chart.dart';
import 'package:airq_ui/app/modules/dashboard/components/selection_summary.dart';
import 'package:airq_ui/app/modules/dashboard/components/station_data.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/visualizations/cluster_means/cluster_means.dart';
import 'package:airq_ui/app/visualizations/multiChart/multi_chart.dart';
import 'package:airq_ui/app/visualizations/std_chart/std_chart.dart';
import 'package:airq_ui/app/widgets/axis.dart';
import 'package:airq_ui/app/widgets/charts/bar_charts/interactive_chart.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection.dart';
import 'package:airq_ui/app/widgets/pcard.dart';
import 'package:airq_ui/app/widgets/stations_map.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../components/aqi_sections.dart';
import '../components/stations_counts.dart';

const double space = 30;

class DashView extends GetView<DashboardController> {
  const DashView({Key? key}) : super(key: key);

  DatasetController get datasetController => Get.find<DatasetController>();

  @override
  Widget build(BuildContext context) {
    // return SizedBox();
    if (controller.globalPoints == null) {
      return const Center(
        child: Text('Select windows'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: pCardSpace,
        vertical: pCardSpace,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          // ** First Row of visualizations
                          child: Row(
                            children: [
                              PCard(
                                child: SizedBox(
                                  width: 100,
                                  child: GetBuilder<DashboardController>(
                                    builder: (_) => ClusterItems(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: pCardSpace),
                              // * Main projection
                              PCard(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: GetBuilder<DatasetController>(
                                    builder: (_) =>
                                        GetBuilder<DashboardController>(
                                      builder: (_) => Obx(
                                        () => Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Visibility(
                                                visible: !datasetController
                                                    .show_filtered,
                                                child: IProjection(
                                                  controller: controller
                                                      .projectionController,
                                                  points:
                                                      controller.globalPoints!,
                                                  onPointsSelected: controller
                                                      .onPointsSelected,
                                                  onPointPicked:
                                                      controller.onPointPicked,
                                                  mode: 0,
                                                  pickMode:
                                                      controller.pickMode.value,
                                                ),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Visibility(
                                                visible: datasetController
                                                    .show_filtered,
                                                child: IProjection(
                                                  controller: controller
                                                      .filterProjectionController,
                                                  points:
                                                      controller.globalPoints!,
                                                  onPointsSelected: controller
                                                      .onPointsSelected,
                                                  onPointPicked:
                                                      controller.onPointPicked,
                                                  mode: 2,
                                                  pickMode:
                                                      controller.pickMode.value,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: pCardSpace),
                              // ** Series view
                              Expanded(
                                child: PCard(
                                  child: GetBuilder<DashboardController>(
                                    builder: (_) => Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 35.0),
                                          child: Row(
                                            children: [
                                              Visibility(
                                                visible: controller
                                                    .clusterIds.isNotEmpty,
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      'Clusters',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: pColorPrimary,
                                                      ),
                                                    ),
                                                    GetBuilder<
                                                        DashboardController>(
                                                      builder: (_) => Switch(
                                                          activeColor:
                                                              pColorPrimary,
                                                          value: controller
                                                                  .ts_visualization !=
                                                              0,
                                                          onChanged:
                                                              (newValue) {
                                                            if (newValue) {
                                                              controller
                                                                  .ts_visualization = 1;
                                                            } else {
                                                              controller
                                                                  .ts_visualization = 0;
                                                            }
                                                            controller.update();
                                                          }),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                datasetController
                                                    .projectedPollutant.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: pColorPrimary,
                                                ),
                                              ),
                                              const Spacer(),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: RepaintBoundary(
                                            child: LeftAxis(
                                              xMaxValue:
                                                  controller.xMaxValueSeries,
                                              xMinValue:
                                                  controller.xMinValueSeries,
                                              yMaxValue: controller.yMaxValue,
                                              yMinValue: controller.yMinValue,
                                              yAxisLabel: datasetController
                                                  .projectedPollutant.name,
                                              xAxisLabel:
                                                  controller.granularity !=
                                                          Granularity.daily
                                                      ? 'days'
                                                      : 'hours',
                                              yDivisions: 5,
                                              xDivisions: controller
                                                          .granularity ==
                                                      Granularity.daily
                                                  ? 24
                                                  : controller.granularity ==
                                                          Granularity.monthly
                                                      ? 5
                                                      : 12,
                                              xLabels: controller.granularity ==
                                                      Granularity.daily
                                                  ? null
                                                  : controller.granularity ==
                                                          Granularity.monthly
                                                      ? [
                                                          "0",
                                                          "7",
                                                          "14",
                                                          '21',
                                                          "29"
                                                        ]
                                                      : [
                                                          "Jan",
                                                          "Feb",
                                                          "Mar",
                                                          "Apr",
                                                          "May",
                                                          "Jun",
                                                          "Jul",
                                                          "Aug",
                                                          "Sep",
                                                          "Oct",
                                                          "Nov",
                                                          "Dec"
                                                        ],
                                              child: controller
                                                          .ts_visualization ==
                                                      0
                                                  ? MultiChart(
                                                      minValue:
                                                          controller.showShape
                                                              ? std_min
                                                              : controller
                                                                  .yMinValue,
                                                      maxValue:
                                                          // controller.showShape
                                                          //     ? std_max
                                                          //     : controller
                                                          //         .yMaxValue,
                                                          controller.showShape
                                                              ? std_max
                                                              : controller
                                                                  .yMaxValue,
                                                      models:
                                                          controller.ipoints,
                                                    )
                                                  : ClusterMeans(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: pCardSpace),
                              // PCard(
                              //   child: AspectRatio(
                              //     aspectRatio: 1,
                              //     child: AqiChart(),
                              //   ),
                              // ),

                              const SizedBox(width: pCardSpace),

                              // ** Pollutant outliers
                              PCard(
                                child: Column(
                                  children: [
                                    Text(
                                      datasetController.projectedPollutant.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: pColorPrimary,
                                      ),
                                    ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: GetBuilder<DashboardController>(
                                          builder: (_) => LeftAxis(
                                            xMaxValue: controller.xMaxValue,
                                            xMinValue: controller.xMinValue,
                                            yMaxValue: controller.yMaxValue,
                                            yMinValue: controller.yMinValue,
                                            xAxisLabel: 'Magnitude',
                                            yAxisLabel: 'Shape',
                                            yDivisions: 5,
                                            xDivisions: 2,
                                            child: Obx(
                                              () => Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: Visibility(
                                                      visible:
                                                          !datasetController
                                                              .show_filtered,
                                                      child: IProjection(
                                                        controller: controller
                                                            .localProjectionController,
                                                        points: controller
                                                            .globalPoints!,
                                                        onPointsSelected:
                                                            controller
                                                                .onPointsSelected,
                                                        onPointPicked:
                                                            controller
                                                                .onPointPicked,
                                                        mode: 1,
                                                        pickMode: controller
                                                            .pickMode.value,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned.fill(
                                                    child: Visibility(
                                                      visible: datasetController
                                                          .show_filtered,
                                                      child: IProjection(
                                                        controller: controller
                                                            .outliersProjectionController,
                                                        points: controller
                                                            .globalPoints!,
                                                        onPointsSelected:
                                                            controller
                                                                .onPointsSelected,
                                                        onPointPicked:
                                                            controller
                                                                .onPointPicked,
                                                        mode: 3,
                                                        pickMode: controller
                                                            .pickMode.value,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: pCardSpace),
                        PCard(
                          height: constraints.maxHeight * 0.14,
                          width: double.infinity,
                          child: GetBuilder<DashboardController>(
                            builder: (_) => RepaintBoundary(
                              child: StationData(
                                windows:
                                    datasetController.selectedStationWindows,
                                selectedWindow:
                                    datasetController.selectedWindow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: pCardSpace),
                        // ** Selection views
                        Expanded(
                          child: GetBuilder<DashboardController>(
                            builder: (_) => Row(
                              children: [
                                Expanded(
                                  child: PCard(
                                    child: RepaintBoundary(
                                      child: SelectionSummary(
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: pCardSpace),
                                Obx(
                                  () => PCard(
                                    width: constraints.minWidth * 0.28,
                                    height: double.infinity,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text('Scale'),
                                            Switch(
                                                value: controller
                                                    .binsPercentage.value,
                                                onChanged: (val) {
                                                  controller.binsPercentage
                                                      .value = val;
                                                }),
                                            Text('Cluster mode'),
                                            Switch(
                                                value: controller
                                                    .binsClusterMode.value,
                                                onChanged: (val) {
                                                  controller.binsClusterMode
                                                      .value = val;
                                                }),
                                          ],
                                        ),
                                        controller.granularity ==
                                                Granularity.daily
                                            ? Expanded(
                                                child: RepaintBoundary(
                                                  child: Visibility(
                                                    visible: controller
                                                            .granularity ==
                                                        Granularity.daily,
                                                    child: InteractiveHistogram(
                                                      percentageMode: controller
                                                          .binsPercentage.value,
                                                      isReseted:
                                                          controller.isReseted,
                                                      values:
                                                          controller.dayCounts,
                                                      allValues: controller
                                                          .allDaysCounts,
                                                      clusterCounts: controller
                                                          .clustersDayCounts,
                                                      clusterColors: controller
                                                          .clusterColors,
                                                      clusterMode: controller
                                                          .binsClusterMode
                                                          .value,
                                                      filterBegin: 0,
                                                      filterEnd: 1,
                                                      labels: const [
                                                        'Mon',
                                                        'Tue',
                                                        'Wed',
                                                        'Thu',
                                                        'Fri',
                                                        'Sat',
                                                        'Sun',
                                                      ],
                                                      onRangeChanged: controller
                                                          .dayRangeSelection,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        Expanded(
                                          child: RepaintBoundary(
                                            child: Visibility(
                                              visible: controller.granularity !=
                                                  Granularity.annual,
                                              child: InteractiveHistogram(
                                                percentageMode: controller
                                                    .binsPercentage.value,
                                                isReseted: controller.isReseted,
                                                values: controller.monthCounts,
                                                allValues:
                                                    controller.allMonthsCounts,
                                                clusterCounts: controller
                                                    .clustersMonthCounts,
                                                clusterColors:
                                                    controller.clusterColors,
                                                clusterMode: controller
                                                    .binsClusterMode.value,
                                                filterBegin: 0,
                                                filterEnd: 1,
                                                labels: const [
                                                  'Jan',
                                                  'Feb',
                                                  'Mar',
                                                  'Apr',
                                                  'May',
                                                  'Jun',
                                                  'Jul',
                                                  'Aug',
                                                  'Sep',
                                                  'Oct',
                                                  'Nov',
                                                  'Dec'
                                                ],
                                                onRangeChanged: controller
                                                    .monthRangeSelection,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: RepaintBoundary(
                                            child: InteractiveHistogram(
                                              percentageMode: controller
                                                  .binsPercentage.value,
                                              isReseted: controller.isReseted,
                                              values: controller.yearCounts,
                                              allValues:
                                                  controller.allYearsCounts,
                                              clusterCounts: controller
                                                  .clustersYearsCounts,
                                              clusterColors:
                                                  controller.clusterColors,
                                              clusterMode: controller
                                                  .binsClusterMode.value,
                                              filterBegin: 0,
                                              filterEnd: 1,
                                              labels: List.generate(
                                                  controller.years.length,
                                                  (index) =>
                                                      (controller.years[index])
                                                          .toString()),
                                              onRangeChanged:
                                                  controller.yearRangeSelection,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: pCardSpace),
                                PCard(
                                  width: constraints.maxWidth * 0.2,
                                  height: double.infinity,
                                  child: RepaintBoundary(
                                    child: Column(
                                      children: [
                                        Visibility(
                                          visible:
                                              // controller.clusterIds.isNotEmpty,
                                              true,
                                          child: Row(
                                            children: [
                                              // Text('Selection based'),
                                              // Switch(
                                              //   value: controller
                                              //       .map_selection_mode,
                                              //   onChanged: (value) {
                                              //     controller
                                              //             .map_selection_mode =
                                              //         value;
                                              //     controller.update();
                                              //   },
                                              // ),
                                              Text('Cluster mode'),
                                              Switch(
                                                value:
                                                    controller.map_cluster_mode,
                                                onChanged: (value) {
                                                  controller.map_cluster_mode =
                                                      value;
                                                  controller.update();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                            child: StationsMap(
                                          selectedBased:
                                              controller.map_selection_mode,
                                          clusterView:
                                              controller.map_cluster_mode,
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: pCardSpace),
                  // Pollutants selection
                  PCard(
                    width: constraints.maxWidth * 0.18,
                    height: double.infinity,
                    child: GetBuilder<DashboardController>(
                      builder: (_) => RepaintBoundary(child: OutliersChart()),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PollutantSelector extends GetView<DashboardController> {
  const _PollutantSelector({Key? key}) : super(key: key);

  DatasetController get datasetController => Get.find();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        hint: Text(
          'Select Item',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: controller.selectedPollutants
            .map((item) => DropdownMenuItem<String>(
                  value: item.name,
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        value: controller.projectedPollutant.name,
        onChanged: (value) {
          controller.selectPollutant(value as String);
        },
        buttonHeight: 40,
        buttonWidth: 140,
        itemHeight: 40,
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> values;
  const _BarChart({
    Key? key,
    required this.values,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          // groupsSpace: 10,
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index].toDouble(),
                  width: 15,
                  color: Colors.amber,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClusterItems extends GetView<DashboardController> {
  const ClusterItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => controller.selectCluster(controller.clusterIds[index]),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: controller.clusterColors[controller.clusterIds[index]]!,
                width: 2,
              ),
              color: controller.clusterColors[controller.clusterIds[index]]!
                  .withOpacity(0.3),
            ),
            height: 25,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AutoSizeText(
              controller.clusterIds[index],
              minFontSize: 8,
              maxFontSize: 16,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
      itemCount: controller.clusterIds.length,
    );
  }
}
