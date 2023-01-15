import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/components/station_item.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/station_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../widgets/pcard.dart';

const double selectorSpaceLeft = 80;
const double selectorSpaceRight = 10;
const double selectorSpaceTop = 30;
const double selectorSpaceBottom = 50;
const double yearsSpace = 45;

class SelectionSummary extends StatefulWidget {
  final double height;
  SelectionSummary({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  State<SelectionSummary> createState() => _SelectionSummaryState();
}

class _SelectionSummaryState extends State<SelectionSummary> {
  ScrollController scrollController = ScrollController();
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();
  Granularity get granularity => datasetController.granularity;
  DateTimeRange get dateRange => datasetController.dateRange;
  late List<StationModel> stations;
  late List<DateTime> dates;
  @override
  void initState() {
    super.initState();
    stations = datasetController.nonEmptyStations;
    computeTotalWindows();
  }

  void computeTotalWindows() {
    print('Computing total windows');
    switch (granularity) {
      case Granularity.daily:
        // totalWindows = dateRange.end.difference(dateRange.start).inDays;
        // dates = [];
        // DateTime temp = dateRange.start;
        // while (temp.isBefore(dateRange.end)) {
        //   dates.add(temp);
        //   temp.add(const Duration(days: 1));
        // }

        dates = [];
        Jiffy temp = Jiffy(
            [dateRange.start.year, dateRange.start.month, dateRange.start.day]);
        while (temp.isBefore(dateRange.end)) {
          dates.add(temp.dateTime);
          temp.add(days: 1);
          // temp.add(const Duration(days: 1));
        }
        break;
      case Granularity.monthly:
        // totalWindows =
        //     (dateRange.end.difference(dateRange.start).inDays / 30).ceil();
        dates = [];
        Jiffy temp = Jiffy(
            [dateRange.start.year, dateRange.start.month, dateRange.start.day]);
        while (temp.isBefore(dateRange.end)) {
          dates.add(temp.dateTime);
          temp.add(months: 1);
          // temp.add(const Duration(days: 1));
        }
        break;
      case Granularity.annual:
        // totalWindows =
        //     (dateRange.end.difference(dateRange.start).inDays / 365).ceil();
        dates = [];
        Jiffy temp = Jiffy(
            [dateRange.start.year, dateRange.start.month, dateRange.start.day]);
        while (temp.isBefore(dateRange.end)) {
          dates.add(temp.dateTime);
          temp.add(years: 1);
          // temp.add(const Duration(days: 1));
        }
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      // controller: scrollController,
      child: Container(
        // color: Colors.amberAccent,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(
            top: selectorSpaceTop,
            bottom: selectorSpaceBottom,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: yearsSpace),
                  child: ListView.separated(
                    controller: scrollController,
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      StationModel station = stations[index];
                      // print('Gathering windows');
                      List<IPoint> points = datasetController
                          .gatherIpointsFromStation(station.id);
                      // print('Gathering done');
                      return StationItem(
                        station: station,
                        ipoints: points,
                        selected: false,
                        dates: dates,
                      );
                    },
                    separatorBuilder: (c, _) => const SizedBox(
                      height: 2,
                    ),
                    itemCount: stations.length,
                    // itemCount: 3,
                  ),
                ),
              ),
              Positioned.fill(child: YearSeparator(dates: dates)),
            ],
          ),
        ),
      ),
    );
  }
}

class YearSeparator extends StatefulWidget {
  List<DateTime> dates;
  YearSeparator({
    Key? key,
    required this.dates,
  }) : super(key: key);

  @override
  State<YearSeparator> createState() => _YearSeparatorState();
}

class _YearSeparatorState extends State<YearSeparator> {
  late List<int> yearPositions;
  late List<int> cumulativeYearPositions;
  @override
  void initState() {
    getYearPositions();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant YearSeparator oldWidget) {
    getYearPositions();
    super.didUpdateWidget(oldWidget);
  }

  void getYearPositions() {
    yearPositions = [];
    DateTime date = widget.dates[0];
    int currPosition = 0;
    for (var i = 0; i < widget.dates.length; i++) {
      if (date.year != widget.dates[i].year) {
        date = widget.dates[i];
        yearPositions.add(i - currPosition);
        currPosition = i;
      }
    }
    yearPositions.add(widget.dates.length - currPosition);

    cumulativeYearPositions = [yearPositions[0]];
    for (var i = 1; i < yearPositions.length; i++) {
      cumulativeYearPositions
          .add(cumulativeYearPositions[i - 1] + yearPositions[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(left: selectorSpaceLeft),
        child: LayoutBuilder(
          builder: (_, constraints) => Container(
            child: Row(
              children: List.generate(
                yearPositions.length,
                (index) {
                  return Column(
                    children: [
                      Container(
                        height: yearsSpace,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(widget
                              .dates[cumulativeYearPositions[index] - 1].year
                              .toString()),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: (constraints.maxWidth / widget.dates.length) *
                              yearPositions[index],
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
