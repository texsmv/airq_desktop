import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/modules/dashboard/components/selection_summary.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/station_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:jiffy/jiffy.dart';

class StationItem extends StatefulWidget {
  StationDateData data;
  StationItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<StationItem> createState() => _StationItemState();
}

class _StationItemState extends State<StationItem> {
  DatasetController get datasetController => Get.find();
  DashboardController get dashboardController => Get.find();
  Granularity get granularity => datasetController.granularity;
  DateTimeRange get dateRange => datasetController.dateRange;

  double get subtileHeight => 25;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: subtileHeight,
      width: double.infinity,
      child: Row(children: [
        Container(
          height: double.infinity,
          width: selectorSpaceLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: subtileHeight,
                width: 25,
                child: Center(
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      // controller.toggleStation(station.id);
                      dashboardController.selectStation(widget.data.station);
                      dashboardController.filterByCharts();
                    },
                    icon: Icon(
                      widget.data.selected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  widget.data.station.name,
                  minFontSize: 8,
                  maxFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            height: subtileHeight,
            child: CustomPaint(
              painter: StationTilePainter(
                points: widget.data.orderedPoints,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class StationTilePainter extends CustomPainter {
  final List<IPoint?> points;
  StationTilePainter({Key? key, required this.points});

  late double width;
  late double height;
  late Canvas _canvas;
  late double _rowHeight;
  late double _itemWidth;
  int get _nDates => points.length;

  // SummaryController summaryController = Get.find();
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();

  @override
  void paint(Canvas canvas, Size size) {
    width = size.width;
    height = size.height;
    _canvas = canvas;

    _rowHeight = height;
    _itemWidth = width / _nDates;
    _drawRow();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawRow() {
    Paint normalPaint = Paint()
      // ..color = colors[pos]
      ..color = pColorGray
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    Paint selectionPaint = Paint()
      ..color = pColorDark
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    Paint emptyPaint = Paint()
      ..color = Color.fromARGB(255, 230, 230, 230)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    Map<String, Paint> clusterPaints = {};
    if (datasetController.clusterIds.isNotEmpty) {
      for (var i = 0; i < datasetController.clusterIds.length; i++) {
        String id = datasetController.clusterIds[i];
        clusterPaints[id] = Paint()
          ..color = dashboardController.clusterColors[id]!
          ..strokeWidth = 1
          ..style = PaintingStyle.fill;
      }
    }
    for (var i = 0; i < _nDates; i++) {
      Paint paint;
      // if (sections[pos][i] && intersection[pos][i]) {
      if (points[i] == null) {
        paint = emptyPaint;
      } else if (points[i]!.cluster != null && points[i]!.selected) {
        paint = clusterPaints[points[i]!.cluster]!;
      } else if (points[i]!.selected) {
        // } else if (selectedIndexes[i]) {
        paint = selectionPaint;
      } else {
        paint = normalPaint;
      }
      double test = 0;
      _canvas.drawRect(
        Rect.fromLTWH(
          i * (_itemWidth - test),
          0,
          (_itemWidth - test),
          _rowHeight,
        ),
        paint,
      );
    }
  }
}

class StationDateData {
  final StationModel station;
  List<IPoint> ipoints;
  final List<DateTime> dates;
  bool selected;
  StationDateData({
    required this.station,
    required this.ipoints,
    required this.selected,
    required this.dates,
  }) {
    orderPoints();
  }

  DatasetController get datasetController => Get.find();
  DashboardController get dashboardController => Get.find();
  Granularity get granularity => datasetController.granularity;
  DateTimeRange get dateRange => datasetController.dateRange;

  late List<IPoint?>
      orderedPoints; // Null value where there is no data from that date

  int get totalWindows => dates.length;

  void orderPoints() {
    List<IPoint> mpoint = List.from(ipoints);
    mpoint.sort((a, b) {
      return a.data.beginDate.compareTo(b.data.beginDate);
    });

    orderedPoints = List.generate(totalWindows, (index) => null);

    int dateP = 0;
    int pointP = 0;
    while (dateP < totalWindows) {
      if (pointP >= mpoint.length) {
        break;
      }
      if (areSameDate(mpoint[pointP].data.beginDate, dates[dateP])) {
        orderedPoints[dateP] = mpoint[pointP];
        pointP++;
      }
      dateP++;
    }
    if (pointP != (mpoint.length - 1) && pointP != (mpoint.length)) {
      print('Error while ordering points');
    }
  }

  bool areSameDate(DateTime a, DateTime b) {
    if (granularity == Granularity.daily) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    } else if (granularity == Granularity.monthly) {
      return a.year == b.year && a.month == b.month;
    } else {
      return a.year == b.year;
    }
  }
}
