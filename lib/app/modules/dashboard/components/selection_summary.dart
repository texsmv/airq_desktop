import 'dart:math';

import 'package:airq_ui/app/modules/dashboard/components/station_item.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/station_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../../widgets/pcard.dart';

const double selectorSpaceLeft = 110;
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
  late List<StationDateData> stationsData;

  @override
  void initState() {
    super.initState();
    stations = datasetController.nonEmptyStations;
    computeTotalWindows();
    createStationsData();
    orderStationsData();
  }

  @override
  void didUpdateWidget(covariant SelectionSummary oldWidget) {
    orderStationsData();
    computeTotalWindows();

    // print(dateRange);
    super.didUpdateWidget(oldWidget);
  }

  void computeTotalWindows() {
    switch (granularity) {
      case Granularity.daily:
        dates = [];
        Jiffy temp = Jiffy(
            [dateRange.start.year, dateRange.start.month, dateRange.start.day]);
        // temp.isBefore(input)
        while (temp.isBefore(dateRange.end)) {
          dates.add(temp.dateTime);
          temp.add(days: 1);
        }
        break;
      case Granularity.monthly:
        dates = [];
        // Jiffy temp = Jiffy.parseFromList(

        //     [dateRange.start.year, dateRange.start.month, dateRange.start.day]);
        Jiffy temp = Jiffy(
            [dateRange.start.year, dateRange.start.month, dateRange.start.day]);
        while (temp.isBefore(dateRange.end)) {
          // while (temp.isBefore(Jiffy.parseFromDateTime(dateRange.end))) {
          dates.add(temp.dateTime);
          temp.add(months: 1);
        }
        break;
      case Granularity.annual:
        dates = [];

        Jiffy temp = Jiffy(
            [dateRange.start.year, dateRange.start.month, dateRange.start.day]);
        while (temp.isBefore(dateRange.end)) {
          dates.add(temp.dateTime);
          temp.add(years: 1);
        }
        dates.add(temp.dateTime);
        temp.add(years: 1);

        // print(dates);
        break;
      default:
    }
  }

  void createStationsData() {
    stationsData = List.generate(stations.length, (index) {
      StationModel station = stations[index];
      List<IPoint> points =
          datasetController.gatherIpointsFromStation(station.id);
      return StationDateData(
        station: station,
        ipoints: points,
        selected: dashboardController.selectedStations[station.id] != null,
        dates: dates,
      );
    });
  }

  void orderStationsData() {
    for (var i = 0; i < stationsData.length; i++) {
      stationsData[i].selected =
          dashboardController.selectedStations[stationsData[i].station.id] !=
              null;
    }
    if (dashboardController.selectedPoints.isNotEmpty) {
      stationsData.sort((a, b) {
        int countA = 0;
        int countB = 0;

        for (var i = 0; i < a.orderedPoints.length; i++) {
          if (a.orderedPoints[i] != null && a.orderedPoints[i]!.selected) {
            countA++;
          }
        }
        for (var i = 0; i < b.orderedPoints.length; i++) {
          if (b.orderedPoints[i] != null && b.orderedPoints[i]!.selected) {
            countB++;
          }
        }
        return countB.compareTo(countA);
      });
    } else {
      stationsData.sort((a, b) {
        int countA = 0;
        int countB = 0;

        for (var i = 0; i < a.orderedPoints.length; i++) {
          if (a.orderedPoints[i] != null) {
            countA++;
          }
        }
        for (var i = 0; i < b.orderedPoints.length; i++) {
          if (b.orderedPoints[i] != null) {
            countB++;
          }
        }
        return countB.compareTo(countA);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return Container(
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
                    return StationItem(
                      data: stationsData[index],
                    );
                  },
                  separatorBuilder: (c, _) => const SizedBox(
                    height: 2,
                  ),
                  itemCount: stationsData.length,
                  // itemCount: 3,
                ),
              ),
            ),
            Positioned.fill(child: YearSeparator(dates: dates)),
          ],
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
    double acum = 0;
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(left: selectorSpaceLeft),
        child: LayoutBuilder(
          builder: (_, constraints) => Container(
            child: Row(
              children: List.generate(
                yearPositions.length,
                (index) {
                  if (index != yearPositions.length - 1) {
                    acum = acum +
                        (constraints.maxWidth / widget.dates.length) *
                            yearPositions[index];
                  }
                  return Column(
                    children: [
                      Container(
                        height: yearsSpace,
                        width: (index == yearPositions.length - 1)
                            ? constraints.maxWidth - acum
                            : (constraints.maxWidth / widget.dates.length) *
                                yearPositions[index],
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(),
                        child: Center(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: AutoSizeText(
                              widget.dates[cumulativeYearPositions[index] - 1]
                                  .year
                                  .toString(),
                              minFontSize: 6,
                              maxFontSize: 14,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: (index == yearPositions.length - 1)
                              ? constraints.maxWidth - acum
                              : (constraints.maxWidth / widget.dates.length) *
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
