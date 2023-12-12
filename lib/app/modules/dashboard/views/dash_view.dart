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
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../components/aqi_sections.dart';
import '../components/stations_counts.dart';

const double space = 30;

class LeftPannel extends GetView<DashboardController> {
  const LeftPannel({super.key});
  DatasetController get datasetController => Get.find<DatasetController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (_) => Column(
        children: [
          // * MAP
          PCard(
            // width: constraints.maxWidth * 0.2,
            height: double.infinity,
            expand: true,
            child: RepaintBoundary(
              child: Column(
                children: [
                  Visibility(
                    visible:
                        // controller.clusterIds.isNotEmpty,
                        true,
                    child: Row(
                      children: [
                        Text('Cluster mode'),
                        Switch(
                          value: controller.map_cluster_mode,
                          onChanged: (value) {
                            controller.map_cluster_mode = value;
                            controller.update();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StationsMap(
                      clusterView: controller.map_cluster_mode,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: pCardSpace),
          PCard(
            expand: true,
            child: RepaintBoundary(
              child: SelectionSummary(
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: pCardSpace),
          Obx(
            () => PCard(
              expand: true,
              // width: constraints.minWidth * 0.28,
              height: double.infinity,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Scale'),
                      Switch(
                          value: controller.binsPercentage.value,
                          onChanged: (val) {
                            controller.binsPercentage.value = val;
                          }),
                      Text('Cluster mode'),
                      Switch(
                        value: controller.binsClusterMode.value,
                        onChanged: (val) {
                          controller.binsClusterMode.value = val;
                        },
                      ),
                    ],
                  ),
                  controller.granularity == Granularity.daily
                      ? Expanded(
                          child: RepaintBoundary(
                            child: Visibility(
                              visible:
                                  controller.granularity == Granularity.daily,
                              child: InteractiveHistogram(
                                percentageMode: controller.binsPercentage.value,
                                isReseted: controller.isReseted,
                                values: controller.dayCounts,
                                allValues: controller.allDaysCounts,
                                clusterCounts: controller.clustersDayCounts,
                                clusterColors: controller.clusterColors,
                                clusterMode: controller.binsClusterMode.value,
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
                                onRangeChanged: controller.dayRangeSelection,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Expanded(
                    child: RepaintBoundary(
                      child: Visibility(
                        visible: controller.granularity != Granularity.annual,
                        child: InteractiveHistogram(
                          percentageMode: controller.binsPercentage.value,
                          isReseted: controller.isReseted,
                          values: controller.monthCounts,
                          allValues: controller.allMonthsCounts,
                          clusterCounts: controller.clustersMonthCounts,
                          clusterColors: controller.clusterColors,
                          clusterMode: controller.binsClusterMode.value,
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
                          onRangeChanged: controller.monthRangeSelection,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RepaintBoundary(
                      child: InteractiveHistogram(
                        percentageMode: controller.binsPercentage.value,
                        isReseted: controller.isReseted,
                        values: controller.yearCounts,
                        allValues: controller.allYearsCounts,
                        clusterCounts: controller.clustersYearsCounts,
                        clusterColors: controller.clusterColors,
                        clusterMode: controller.binsClusterMode.value,
                        filterBegin: 0,
                        filterEnd: 1,
                        labels: List.generate(controller.years.length,
                            (index) => (controller.years[index]).toString()),
                        onRangeChanged: controller.yearRangeSelection,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RigthPannel extends GetView<DashboardController> {
  DatasetController get datasetController => Get.find<DatasetController>();
  const RigthPannel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PCard(
          child: AqiChart(),
          expand: true,
        ),
        const SizedBox(height: pCardSpace),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: PCard(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GetBuilder<DashboardController>(
                      builder: (_) => Column(
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
                            child: LeftAxis(
                              xMinValue: 0,
                              xMaxValue: 1,
                              yMinValue: 0,
                              yMaxValue: 1,
                              xAxisLabel: 'Magnitude',
                              yAxisLabel: 'Shape',
                              yDivisions: 2,
                              xDivisions: 2,
                              child: Obx(
                                () => Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Visibility(
                                        visible:
                                            !datasetController.show_filtered,
                                        child: IProjection(
                                          controller: controller
                                              .localProjectionController,
                                          points: controller.ipoints,
                                          onPointsSelected:
                                              controller.onPointsSelected,
                                          onPointPicked:
                                              controller.onPointPicked,
                                          mode: 1,
                                          pickMode: controller.pickMode.value,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Visibility(
                                        visible:
                                            datasetController.show_filtered,
                                        child: IProjection(
                                          controller: controller
                                              .outliersProjectionController,
                                          points: controller.ipoints,
                                          onPointsSelected:
                                              controller.onPointsSelected,
                                          onPointPicked:
                                              controller.onPointPicked,
                                          mode: 3,
                                          pickMode: controller.pickMode.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PCard(
                  // width: constraints.maxWidth * 0.18,
                  height: double.infinity,
                  child: GetBuilder<DashboardController>(
                    builder: (_) => RepaintBoundary(
                      child: OutliersChart(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class MidPannel extends GetView<DashboardController> {
  const MidPannel({super.key});
  DatasetController get datasetController => Get.find<DatasetController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      return Column(
        children: [
          Expanded(
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
                Expanded(
                  child: PCard(
                    child: GetBuilder<DatasetController>(
                      builder: (_) => GetBuilder<DashboardController>(
                        builder: (_) => Obx(
                          () => Stack(
                            children: [
                              Positioned.fill(
                                child: Visibility(
                                  visible: !datasetController.show_filtered,
                                  child: IProjection(
                                    controller: controller.projectionController,
                                    points: controller.ipoints,
                                    onPointsSelected:
                                        controller.onPointsSelected,
                                    onPointPicked: controller.onPointPicked,
                                    mode: 0,
                                    pickMode: controller.pickMode.value,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Visibility(
                                  visible: datasetController.show_filtered,
                                  child: IProjection(
                                    controller:
                                        controller.filterProjectionController,
                                    points: controller.ipoints,
                                    onPointsSelected:
                                        controller.onPointsSelected,
                                    onPointPicked: controller.onPointPicked,
                                    mode: 2,
                                    pickMode: controller.pickMode.value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: pCardSpace),
          !controller.pickMode.value
              ? Expanded(
                  flex: 3,
                  child: ListView.separated(
                      separatorBuilder: (_, i) => SizedBox(height: 25),
                      itemCount: controller.pollutants.length,
                      itemBuilder: (_, index) {
                        List<PollutantModel> pollutants =
                            List<PollutantModel>.from(controller.pollutants);
                        pollutants.sort((a, b) =>
                            b.selectionRank.compareTo(a.selectionRank));

                        PollutantModel pollutant = pollutants[index];

                        return PCard(
                          height: 200,
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(pollutant.name),
                              Expanded(
                                child: Container(
                                  child: RepaintBoundary(
                                    child: LeftAxis(
                                      xMaxValue: controller.xMaxValueSeries,
                                      xMinValue: controller.xMinValueSeries,
                                      yMaxValue: datasetController
                                          .maxSmoothedValues[pollutant.id]!,
                                      yMinValue: datasetController
                                          .minSmoothedValues[pollutant.id]!,
                                      yAxisLabel: '',
                                      xAxisLabel: controller.granularity !=
                                              Granularity.daily
                                          ? 'days'
                                          : 'hours',
                                      yDivisions: 5,
                                      xDivisions: controller.granularity ==
                                              Granularity.daily
                                          ? 5
                                          : controller.granularity ==
                                                  Granularity.monthly
                                              ? 5
                                              : 12,
                                      xLabels: controller.granularity ==
                                              Granularity.daily
                                          ? ['0', '6', '12', '18', '24']
                                          : controller.granularity ==
                                                  Granularity.monthly
                                              ? ["1", "7", "14", '21', "28"]
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
                                      child: controller.ts_visualization == 0
                                          ? MultiChart(
                                              key: Key(pollutant.name),
                                              pollutant: pollutant,
                                              minValue: controller.showShape
                                                  ? std_min
                                                  : datasetController
                                                          .minSmoothedValues[
                                                      pollutant.id]!,
                                              maxValue:
                                                  // controller.showShape
                                                  //     ? std_max
                                                  //     : controller
                                                  //         .yMaxValue,
                                                  controller.showShape
                                                      ? std_max
                                                      : datasetController
                                                              .maxSmoothedValues[
                                                          pollutant.id]!,
                                              models: controller.ipoints,
                                            )
                                          : ClusterMeans(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                )
              : Expanded(
                  flex: 3,
                  child: PCard(
                    child: StationData(
                      windows: datasetController.selectedStationWindows,
                      selectedWindow: datasetController.selectedWindow,
                    ),
                  ),
                ),
        ],
      );
    });
  }
}

class DashView extends GetView<DashboardController> {
  const DashView({Key? key}) : super(key: key);

  DatasetController get datasetController => Get.find<DatasetController>();

  @override
  Widget build(BuildContext context) {
    // return SizedBox();
    if (controller.ipoints == null) {
      return const Center(
        child: Text('Select windows'),
      );
    }
    // return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: pCardSpace,
        vertical: pCardSpace,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: LeftPannel(),
          ),
          SizedBox(width: pCardSpace),
          Expanded(flex: 2, child: MidPannel()),
          SizedBox(width: pCardSpace),
          Expanded(flex: 3, child: RigthPannel()),
        ],
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
        // buttonHeight: 40,
        // buttonWidth: 140,
        // itemHeight: 40,
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
    print(controller.clusterIds);
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
