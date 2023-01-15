import 'dart:math';

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
  final StationModel station;
  List<IPoint> ipoints;
  final List<DateTime> dates;
  final bool selected;
  StationItem({
    Key? key,
    required this.station,
    required this.ipoints,
    required this.selected,
    required this.dates,
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

  late List<IPoint?>
      orderedPoints; // Null value where there is no data from that date

  int get totalWindows => dates.length;
  List<DateTime> get dates => widget.dates;

  @override
  void initState() {
    // computeTotalWindows();
    orderPoints();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StationItem oldWidget) {
    // computeTotalWindows();
    // orderPoints();
    super.didUpdateWidget(oldWidget);
  }

  void orderPoints() {
    print('---- Station ID: ${widget.station.name} starting ----');
    List<IPoint> mpoint = List.from(widget.ipoints);
    mpoint.sort((a, b) {
      return a.data.beginDate.compareTo(b.data.beginDate);
    });
    print('Sort done');

    orderedPoints = List.generate(totalWindows, (index) => null);

    int dateP = 0;
    int pointP = 0;
    print('Bucle');
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
    print('Station ID: ${widget.station.name} completed');
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
                    },
                    icon: Icon(
                      widget.selected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  widget.station.name,
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
                points: orderedPoints,
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
      ..color = Colors.blue
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    Paint selectionPaint = Paint()
      ..color = Colors.red
      // ..color = Color.fromRGBO(
      //   min(255, colors[pos].red * 2.7).toInt(),
      //   min(255, colors[pos].green * 2.7).toInt(),
      //   min(255, colors[pos].blue * 2.7).toInt(),
      //   colors[pos].opacity,

      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    Paint emptyPaint = Paint()
      ..color = const Color.fromRGBO(240, 190, 20, 1)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    for (var i = 0; i < _nDates; i++) {
      Paint paint;
      // if (sections[pos][i] && intersection[pos][i]) {
      if (points[i] == null) {
        paint = emptyPaint;
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

// class StationItem extends GetView<SummaryController> {
//   final List<Color> colors;
//   final List<List<bool>> sections;
//   final List<List<bool>> intersection;
//   final String name;
//   final StationModel station;
//   final bool selected;
//   final int index;
//   StationItem({
//     Key? key,
//     required this.colors,
//     required this.sections,
//     required this.name,
//     required this.selected,
//     required this.intersection,
//     required this.station,
//     required this.index,
//   }) : super(key: key);

//   List<bool>? _selectedIndexes;
//   List<bool> get selectedIndexes {
//     if (_selectedIndexes != null) return _selectedIndexes!;
//     _selectedIndexes = List.generate(sections.first.length, (index) => false);

//     for (var j = 0; j < sections.first.length; j++) {
//       bool colVal = true;
//       for (var i = 0; i < sections.length; i++) {
//         colVal = sections[i][j] && colVal;
//       }
//       _selectedIndexes![j] = colVal;
//     }
//     return _selectedIndexes!;
//   }

//   List<String> get selectedPollutants => List.generate(
//       controller.selectedPollutants.length,
//       (index) => controller.selectedPollutants[index].name);
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: max(subtileHeight * sections.length, 10),
//       child: Row(
//         children: [
//           SizedBox(
//             width: selectorSpaceLeft,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: 25,
//                   width: 25,
//                   child: Center(
//                     child: IconButton(
//                       padding: const EdgeInsets.all(0),
//                       onPressed: () {
//                         controller.toggleStation(station.id);
//                       },
//                       icon: Icon(
//                         selected
//                             ? Icons.check_box
//                             : Icons.check_box_outline_blank,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     "${index.toString()}.-${station.name}",
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: SizedBox(
//               height: subtileHeight * sections.length,
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: SizedBox(
//                       height: subtileHeight * sections.length,
//                       child: CustomPaint(
//                         painter: StationTilePainter(
//                           isSelected: selected,
//                           intersection: intersection,
//                           colors: colors,
//                           sections: sections,
//                           selectedIndexes: selectedIndexes,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned.fill(
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: List.generate(
//                           sections.length,
//                           (index) => Text(
//                             selectedPollutants[index],
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w500,
//                               shadows: <Shadow>[
//                                 Shadow(
//                                   offset: Offset(1.0, 1.0),
//                                   blurRadius: 0.3,
//                                   color: Color.fromARGB(255, 0, 0, 0),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: selectorSpaceRight),
//         ],
//       ),
//     );
//   }
// }

// class StationTilePainter extends CustomPainter {
//   final List<Color> colors;
//   final List<List<bool>> sections;
//   final List<List<bool>> intersection;
//   final List<bool> selectedIndexes;
//   final bool isSelected;

//   StationTilePainter({
//     Key? key,
//     required this.colors,
//     required this.sections,
//     required this.intersection,
//     required this.selectedIndexes,
//     required this.isSelected,
//   });

//   late double width;
//   late double height;
//   late Canvas _canvas;
//   late double _rowHeight;
//   late double _itemWidth;
//   int get _nDates => sections.first.length;

//   SummaryController summaryController = Get.find();

//   @override
//   void paint(Canvas canvas, Size size) {
//     width = size.width;
//     height = size.height;
//     _canvas = canvas;

//     _rowHeight = height / sections.length;
//     _itemWidth = width / _nDates;
//     for (var i = 0; i < sections.length; i++) {
//       _drawRow(i);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }

//   void _drawRow(int pos) {
//     Paint normalPaint = Paint()
//       ..color = colors[pos]
//       ..strokeWidth = 1
//       ..style = PaintingStyle.fill;

//     Paint intersectionPaint = Paint()
//       ..color = Color.fromRGBO(
//         min(255, colors[pos].red * 2.7).toInt(),
//         min(255, colors[pos].green * 2.7).toInt(),
//         min(255, colors[pos].blue * 2.7).toInt(),
//         colors[pos].opacity,
//       )
//       ..strokeWidth = 1
//       ..style = PaintingStyle.fill;

//     Paint emptyPaint = Paint()
//       ..color = const Color.fromRGBO(240, 190, 20, 1)
//       ..strokeWidth = 1
//       ..style = PaintingStyle.fill;

//     for (var i = 0; i < _nDates; i++) {
//       Paint paint;
//       // if (sections[pos][i] && intersection[pos][i]) {
//       if (isSelected &&
//           selectedIndexes[i] &&
//           summaryController.windowSelectedIndexes[i]) {
//         paint = intersectionPaint;
//       } else if (sections[pos][i]) {
//         // } else if (selectedIndexes[i]) {
//         paint = normalPaint;
//       } else {
//         paint = emptyPaint;
//       }
//       double test = 0;
//       _canvas.drawRect(
//         Rect.fromLTWH(
//           i * (_itemWidth - test),
//           pos * _rowHeight,
//           (_itemWidth - test),
//           _rowHeight,
//         ),
//         paint,
//       );
//     }
//   }
// }
