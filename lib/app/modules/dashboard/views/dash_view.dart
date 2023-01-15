import 'package:airq_ui/app/constants/constants.dart';
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
                              PCard(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: GetBuilder<DashboardController>(
                                    builder: (_) => Obx(
                                      () => IProjection(
                                        controller:
                                            controller.projectionController,
                                        points: controller.globalPoints!,
                                        onPointsSelected:
                                            controller.onPointsSelected,
                                        onPointPicked: controller.onPointPicked,
                                        isLocal: false,
                                        pickMode: controller.pickMode.value,
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
                                    builder: (_) => LeftAxis(
                                      xMaxValue: controller.xMaxValueSeries,
                                      xMinValue: controller.xMinValueSeries,
                                      yMaxValue: controller.ts_visualization ==
                                              0
                                          ? controller.yMaxValue
                                          : datasetController.maxMeansValue ??
                                              1,
                                      yMinValue: controller.ts_visualization ==
                                              0
                                          ? controller.yMinValue
                                          : datasetController.minMeansValue ??
                                              0,
                                      yAxisLabel: 'Magnitude',
                                      xAxisLabel: 'Time',
                                      yDivisions: 5,
                                      xDivisions: 12,
                                      xLabels: controller.granularity !=
                                              Granularity.annual
                                          ? null
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
                                              minValue: controller.showShape
                                                  ? std_min
                                                  : controller.yMinValue,
                                              maxValue: controller.showShape
                                                  ? std_max
                                                  : controller.yMaxValue,
                                              models: controller.ipoints,
                                            )
                                          : ClusterMeans(),
                                      // : StdChart(
                                      //   minValue: controller.yMinValue,
                                      //   maxValue: controller.yMaxValue,
                                      //   ipoints: controller.ipoints,
                                      // ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: pCardSpace),

                              // ** Pollutant outliers
                              PCard(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: GetBuilder<DashboardController>(
                                    builder: (_) => LeftAxis(
                                      xMaxValue: controller.xMaxValue,
                                      xMinValue: controller.xMinValue,
                                      yMaxValue: controller.yMaxValue,
                                      yMinValue: controller.yMinValue,
                                      yAxisLabel: 'Magnitude',
                                      xAxisLabel: 'Shape',
                                      yDivisions: 5,
                                      xDivisions: 2,
                                      child: AqiSections(
                                        showIaqi: uiHasIaqi(
                                            controller.projectedPollutant.name),
                                        minValue: 0,
                                        maxValue: uiPollutant2Aqi(
                                            controller.yMaxValue,
                                            controller.projectedPollutant.name),
                                        child: Obx(
                                          () => IProjection(
                                            controller: controller
                                                .localProjectionController,
                                            points: controller.globalPoints!,
                                            onPointsSelected:
                                                controller.onPointsSelected,
                                            onPointPicked:
                                                controller.onPointPicked,
                                            isLocal: true,
                                            pickMode: controller.pickMode.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                    child: SelectionSummary(
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: pCardSpace),
                                PCard(
                                  width: constraints.minWidth * 0.28,
                                  height: double.infinity,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Visibility(
                                          visible: controller.granularity ==
                                              Granularity.daily,
                                          child: InteractiveHistogram(
                                            isReseted: controller.isReseted,
                                            values: controller.dayCounts,
                                            allValues: controller.allDaysCounts,
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
                                            onRangeChanged:
                                                controller.dayRangeSelection,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Visibility(
                                          visible: controller.granularity !=
                                              Granularity.annual,
                                          child: InteractiveHistogram(
                                            isReseted: controller.isReseted,
                                            values: controller.monthCounts,
                                            allValues:
                                                controller.allMonthsCounts,
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
                                            onRangeChanged:
                                                controller.monthRangeSelection,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InteractiveHistogram(
                                          isReseted: controller.isReseted,
                                          values: controller.yearCounts,
                                          allValues: controller.allYearsCounts,
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
                                    ],
                                  ),
                                ),
                                const SizedBox(width: pCardSpace),
                                PCard(
                                  width: constraints.maxWidth * 0.2,
                                  height: double.infinity,
                                  child: StationsMap(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: pCardSpace),
                        PCard(
                          height: constraints.maxHeight * 0.14,
                          width: double.infinity,
                          child: GetBuilder<DashboardController>(
                            builder: (_) => StationData(
                              windows: datasetController.selectedStationWindows,
                              selectedWindow: datasetController.selectedWindow,
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
                      builder: (_) => OutliersChart(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: space, vertical: space),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      PCard(
                        child: SizedBox(
                          width: 150,
                          child: GetBuilder<DashboardController>(
                            builder: (_) => ClusterItems(),
                          ),
                        ),
                      ),
                      const SizedBox(width: space),
                      Expanded(
                        child: PCard(
                          child: GetBuilder<DashboardController>(
                            builder: (_) => Obx(
                              () => Column(
                                children: [
                                  Switch(
                                    value: controller.pickMode.value,
                                    onChanged: (newVal) {
                                      controller.pickMode.value = newVal;
                                    },
                                  ),
                                  Expanded(
                                    child: IProjection(
                                      controller:
                                          controller.projectionController,
                                      points: controller.globalPoints!,
                                      onPointsSelected:
                                          controller.onPointsSelected,
                                      onPointPicked: controller.onPointPicked,
                                      isLocal: false,
                                      pickMode: controller.pickMode.value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: space),
                GetBuilder<DashboardController>(builder: (_) {
                  if (datasetController.contFeatMap == null) {
                    return const SizedBox();
                  }

                  return SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: PCard(
                      child: CFeaturesChart(
                        // values: List.generate(
                        //     datasetController.contrastiveFeatures!.length,
                        //     (index) => datasetController
                        //         .contrastiveFeatures![index]
                        //         .sublist(0, 30)),
                        values: datasetController.contrastiveFeatures,

                        colors: List.generate(
                            datasetController.contFeatMap!.keys.length,
                            (index) => datasetController.clusterColors[
                                datasetController.contFeatMap!.keys
                                    .toList()[index]
                                    .toString()]!),
                        // colors: datasetController.clusterColors.values.toList(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: space),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: PCard(
                          child: Container(
                            child: GetBuilder<DashboardController>(
                              // tag: 'local',
                              builder: (_) => Column(
                                children: [
                                  _PollutantSelector(),
                                  Divider(),
                                  Expanded(
                                    child: LeftAxis(
                                      xMaxValue: controller.xMaxValue,
                                      xMinValue: controller.xMinValue,
                                      // yMaxValue: controller.ts_visualization ==
                                      //         0
                                      //     ? controller.yMaxValue
                                      //     : datasetController.maxMeansValue ??
                                      //         1,
                                      // yMinValue: controller.ts_visualization ==
                                      //         0
                                      //     ? controller.yMinValue
                                      //     : datasetController.minMeansValue ??
                                      //         0,

                                      yMaxValue: controller.yMaxValue,

                                      yMinValue: controller.yMinValue,
                                      yAxisLabel: 'Magnitude',
                                      xAxisLabel: 'Shape',
                                      yDivisions: 5,
                                      xDivisions: 2,
                                      child: AqiSections(
                                        showIaqi: uiHasIaqi(
                                            controller.projectedPollutant.name),
                                        minValue: 0,
                                        maxValue: uiPollutant2Aqi(
                                            controller.yMaxValue,
                                            controller.projectedPollutant.name),
                                        child: Obx(
                                          () => IProjection(
                                            controller: controller
                                                .localProjectionController,
                                            points: controller.globalPoints!,
                                            onPointsSelected:
                                                controller.onPointsSelected,
                                            onPointPicked:
                                                controller.onPointPicked,
                                            isLocal: true,
                                            pickMode: controller.pickMode.value,
                                          ),
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
                      const SizedBox(width: space),
                      Expanded(
                        child: PCard(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0),
                                child: Visibility(
                                  visible: true,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Visualization'),
                                      GetBuilder<DashboardController>(
                                        builder: (_) => Switch(
                                            value:
                                                controller.ts_visualization ==
                                                    0,
                                            onChanged: (newValue) {
                                              if (newValue) {
                                                controller.ts_visualization = 0;
                                              } else {
                                                controller.ts_visualization = 1;
                                              }
                                              controller.update();
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0),
                                child: Visibility(
                                  visible: true,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Shape'),
                                      GetBuilder<DashboardController>(
                                        builder: (_) => Switch(
                                            value: controller.showShape,
                                            onChanged: (newValue) {
                                              controller.showShape = newValue;
                                              controller.update();
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  child: GetBuilder<DashboardController>(
                                    builder: (_) => LeftAxis(
                                      xMaxValue: controller.xMaxValueSeries,
                                      xMinValue: controller.xMinValueSeries,
                                      // yMaxValue: controller.yMaxValue,
                                      // yMinValue: controller.yMinValue,

                                      yMaxValue: controller.ts_visualization ==
                                              0
                                          ? controller.yMaxValue
                                          : datasetController.maxMeansValue ??
                                              1,
                                      yMinValue: controller.ts_visualization ==
                                              0
                                          ? controller.yMinValue
                                          : datasetController.minMeansValue ??
                                              0,

                                      // yMinValue: controller.showShape
                                      //     ? std_min
                                      //     : controller.yMinValue,
                                      // yMaxValue: controller.showShape
                                      //     ? std_max
                                      //     : controller.yMaxValue,
                                      yAxisLabel: 'Magnitude',
                                      xAxisLabel: 'Time',
                                      yDivisions: 5,
                                      xDivisions: 12,
                                      xLabels: controller.granularity !=
                                              Granularity.annual
                                          ? null
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
                                              minValue: controller.showShape
                                                  ? std_min
                                                  : controller.yMinValue,
                                              maxValue: controller.showShape
                                                  ? std_max
                                                  : controller.yMaxValue,
                                              models: controller.ipoints,
                                            )
                                          : ClusterMeans(),
                                      // : StdChart(
                                      //   minValue: controller.yMinValue,
                                      //   maxValue: controller.yMaxValue,
                                      //   ipoints: controller.ipoints,
                                      // ),
                                    ),
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
                const SizedBox(height: 10),
                PCard(
                  child: SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: GetBuilder<DashboardController>(builder: (_) {
                      return StationData(
                        windows: datasetController.selectedStationWindows,
                        selectedWindow: datasetController.selectedWindow,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: space),
          Expanded(
            flex: 2,
            child: PCard(
              child: GetBuilder<DashboardController>(
                builder: (_) => SingleChildScrollView(
                  child: Column(
                    children: [
                      StationsMap(),
                      const SizedBox(height: 10),
                      SelectionSummary(
                        height: 300,
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                        visible: controller.granularity == Granularity.daily,
                        child: InteractiveHistogram(
                          isReseted: controller.isReseted,
                          values: controller.dayCounts,
                          allValues: controller.allDaysCounts,
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
                      Visibility(
                        visible: controller.granularity != Granularity.annual,
                        child: InteractiveHistogram(
                          isReseted: controller.isReseted,
                          values: controller.monthCounts,
                          allValues: controller.allMonthsCounts,
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
                      InteractiveHistogram(
                        isReseted: controller.isReseted,
                        values: controller.yearCounts,
                        allValues: controller.allYearsCounts,
                        filterBegin: 0,
                        filterEnd: 1,
                        labels: List.generate(controller.years.length,
                            (index) => (controller.years[index]).toString()),
                        onRangeChanged: controller.yearRangeSelection,
                      ),
                      // StationsCounts(),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
            child: Text(
              controller.clusterIds[index],
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
