import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/list_shape_ext.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:airq_ui/models/station_model.dart';
import 'package:airq_ui/models/window_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class StationData extends StatefulWidget {
  final List<WindowModel>? windows;
  final WindowModel? selectedWindow;
  const StationData({
    Key? key,
    required this.windows,
    required this.selectedWindow,
  }) : super(key: key);

  @override
  _StationDataState createState() => _StationDataState();
}

class _StationDataState extends State<StationData> {
  DatasetController controller = Get.find();
  DashboardController dashboardController = Get.find();
  late double minValue;
  late double maxValue;
  // List<WindowModel>? orderedWindows;
  late ScrollController scrollController;
  StationModel get station => controller.stations
      .firstWhere((element) => element.id == widget.selectedWindow!.stationId);
  @override
  void initState() {
    scrollController = ScrollController();
    if (widget.windows != null) {
      orderWindows();
      minMaxValues();
      moveToWindow();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StationData oldWidget) {
    if (widget.windows != null) {
      orderWindows();
      minMaxValues();
      moveToWindow();
    }
    super.didUpdateWidget(oldWidget);
  }

  void minMaxValues() {
    minValue = controller.minValue;
    maxValue = controller.maxValue;
  }

  void orderWindows() {
    widget.windows!.sort((a, b) {
      return a.beginDate.compareTo(b.beginDate);
    });
  }

  void moveToWindow() {
    if (widget.windows == null) return;
    if (!scrollController.hasClients) {
      return;
    }
    int windowPosition = widget.windows!
        .indexWhere((element) => element.id == widget.selectedWindow!.id);

    int position = windowPosition;
    if (position < 0) {
      return;
    }
    scrollController.position.moveTo(80.0 * (position - 4));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.windows == null) return const SizedBox();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          width: 70,
          child: AutoSizeText(
            station.name,
            maxLines: 2,
            maxFontSize: 16,
            minFontSize: 11,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: ListView.builder(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.windows!.length,
                  itemBuilder: (context, index) {
                    DateTime date = widget.windows![index].beginDate;
                    bool isSameMonth = widget.selectedWindow!.beginDate.month ==
                        widget.windows![index].beginDate.month;
                    bool isSelected =
                        widget.selectedWindow!.id == widget.windows![index].id;
                    return Container(
                      width: 80,
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.selectedWindow =
                                    widget.windows![index];
                                dashboardController.update();
                              },
                              child: Container(
                                width: 80,
                                height: double.infinity,
                                color: widget.selectedWindow!.id ==
                                        widget.windows![index].id
                                    ? pColorPrimary.withOpacity(0.4)
                                    : Colors.white,
                                child: CustomPaint(
                                  painter: BarChartPainter(
                                    color: widget.selectedWindow!.id ==
                                            widget.windows![index].id
                                        ? pColorPrimary
                                        : Color.fromRGBO(123, 123, 123, 1),
                                    minValue: 0,
                                    maxValue: maxValue,
                                    values: widget.windows![index].values[
                                        controller.projectedPollutant.id]!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 12,
                            child: Text(
                              windowName(date, isSelected),
                              style: const TextStyle(
                                  fontSize: 11,
                                  // color: isSameMonth
                                  //     ? pTextColorSecondary
                                  //     : Colors.transparent,
                                  color: pTextColorSecondary),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String windowName(DateTime date, bool isSelected) {
    if (controller.granularity == Granularity.monthly) {
      return uiMonthNameByIndex(date.month) + " " + date.year.toString();
    } else if (controller.granularity == Granularity.annual) {
      return date.year.toString();
    } else {
      if (isSelected) {
        return date.toString().substring(0, 10) +
            ' ' +
            uiWeekDayStr(date.weekday);
      } else {
        return date.toString().substring(0, 10);
      }
    }
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class BarChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;
  final Color color;
  // final List<Color> cores;
  BarChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
    required this.color,
  });

  late double _width;
  late double _height;
  late Canvas _canvas;
  late double _horizontalSpace;
  late double _barWidth;
  late double _minValue;
  late double _maxValue;
  late int _nTime;

  // int get timeLen => models.first.data.values.values.toList().first.length;
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();
  PollutantModel get pollutant => datasetController.projectedPollutant;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _width = size.width;
    _height = size.height;

    List<double> allValues = List<double>.from(values.flatten());
    _minValue = minValue;
    _maxValue = maxValue;

    _nTime = values.length;

    _horizontalSpace = 0;
    // _barWidth = (_width - (_horizontalSpace * (_nClusters - 1))) / _nTime;
    _barWidth = (_width - (_horizontalSpace * (_nTime - 1))) / (_nTime);

    double leftOffset = 0;
    for (var i = 0; i < _nTime; i++) {
      Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      Offset begin = Offset(leftOffset, value2Heigh(0));
      Offset end = Offset(leftOffset + _barWidth, value2Heigh(values[i]));

      _canvas.drawRect(
        Rect.fromPoints(begin, end),
        paint,
      );
      leftOffset = leftOffset + _barWidth;
      leftOffset + _horizontalSpace;
    }
    // for (var i = 0; i < models.length; i++) {
    //   if (models[i].selected) {
    //     paintModelLine(models[i]);
    //   }
    // }
  }

  double value2Heigh(double value) {
    return _height - uiRangeConverter(value, _minValue, _maxValue, 0, _height);
    // return _height - (value / visSettings.datasetSettings.maxValue * _height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
