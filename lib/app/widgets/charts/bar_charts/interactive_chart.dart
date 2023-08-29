import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef RangeChangeCallback = void Function(int begin, int end);

class InteractiveHistogram extends StatefulWidget {
  final RxBool isReseted;
  final List<int> values;
  final List<int> allValues;
  final List<String> labels;
  final Map<String, List<int>> clusterCounts;
  final Map<String, Color> clusterColors;
  final bool clusterMode;
  final int filterBegin;

  /// not inclusive values in range don't include this value
  final int filterEnd;
  final RangeChangeCallback onRangeChanged;
  final bool showHandlers;
  bool percentageMode = false;

  InteractiveHistogram({
    Key? key,
    required this.values,
    required this.allValues,
    required this.labels,
    required this.filterBegin,
    required this.filterEnd,
    required this.onRangeChanged,
    required this.isReseted,
    required this.percentageMode,
    required this.clusterCounts,
    required this.clusterColors,
    required this.clusterMode,
    this.showHandlers = true,
  }) : super(key: key);

  @override
  _InteractiveHistogramState createState() => _InteractiveHistogramState();
}

class _InteractiveHistogramState extends State<InteractiveHistogram> {
  late double _width;
  late double _height;
  double _dragWidth = 15;
  int get filterSize => widget.labels.length;

  late double beginPosition;
  late double endPosition;

  /// to select new area
  late double beginDragPosition;

  /// to select new area
  late double endDragPosition;
  double get selectedAreaWidth => endPosition - beginPosition;
  late int beginRange;
  late int endRange;

  int get allMaxCount => widget.allValues.reduce(max);
  int get maxCount => widget.values.reduce(max);

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
  }

  double plotBarHeight(int value) {
    double maxBarHeight;
    if (widget.percentageMode && !widget.clusterMode) {
      maxBarHeight = maxCount.toDouble();
    } else {
      maxBarHeight = allMaxCount.toDouble();
    }

    if (widget.clusterMode) {
      maxBarHeight = allMaxCount.toDouble();
    }

    final double newVal =
        uiRangeConverter(value.toDouble(), 0, maxBarHeight, 0, _height);
    return newVal;
  }

  double range2Width(double value) {
    final double newVal = uiRangeConverter(
        value, 0, filterSize.toDouble() - 1, 0, _width - _dragWidth);
    return newVal;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.length != widget.allValues.length) {
      return SizedBox();
    }
    return Column(
      children: [
        Expanded(
          child: Container(
            child: LayoutBuilder(builder: (context, constraints) {
              _height = constraints.maxHeight;
              _width = constraints.maxWidth;
              if (firstBuild) {
                beginPosition = range2Width(widget.filterBegin.toDouble());
                endPosition = range2Width(widget.filterEnd.toDouble() - 1);
                beginRange = widget.filterBegin;
                endRange = widget.filterEnd;
              }
              firstBuild = false;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: _dragWidth),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          widget.allValues.length,
                          (index) => Expanded(
                            child: AnimatedContainer(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: const Color.fromRGBO(200, 200, 200, 1),
                              ),
                              duration: const Duration(milliseconds: 250),
                              width: 20,
                              // height: 100,
                              height: plotBarHeight(
                                widget.allValues[index],
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.values[index].toString()}',
                                  style: const TextStyle(
                                    color: pTextColorPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // _selectionBars(),
                  widget.clusterMode ? _clusterBars() : _selectionBars(),
                  _wholeArea(),
                  _selectedArea(constraints),
                  _leftHanfler(constraints),
                  _rightHanfler(constraints),
                ],
              );
            }),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _dragWidth),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.labels.length,
              (index) => Expanded(
                child: Column(
                  children: [
                    RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          widget.labels[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Text(widget.allValues[index].toString()),
                    // Text(),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _clusterBars() {
    List<String> clusterIds = widget.clusterColors.keys.toList();
    // print('BAR PLOT');
    // print(allMaxCount);
    // print(plotBarHeight(allMaxCount));
    // print('');
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _dragWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.values.length, (index) {
            // print('INDEX');
            // print(index);
            return Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(clusterIds.length, (clustIndex) {
                    int clusterCounts =
                        widget.clusterCounts[clusterIds[clustIndex]]![index];
                    // print(clusterCounts);
                    // print(plotBarHeight(clusterCounts));
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          color: widget.clusterColors[clusterIds[clustIndex]]),
                      height: plotBarHeight(clusterCounts),
                    );
                  })),
            );
          }),
        ),
      ),
    );
  }

  Widget _selectionBars() {
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _dragWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            widget.values.length,
            (index) => Expanded(
              child: AnimatedContainer(
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  color: pColorPrimary,
                ),
                duration: Duration(milliseconds: 250),
                // width: 20,
                // height: 100,
                height: plotBarHeight(
                  widget.values[index],
                ),
                child: Center(
                  child: Text(
                    '${widget.values[index].toString()}',
                    style: const TextStyle(
                      color: pTextColorPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wholeArea() {
    return Positioned(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          beginDragPosition = details.localPosition.dx;
          widget.isReseted.value = false;
        },
        onHorizontalDragEnd: (details) {
          if ((beginPosition - endPosition).abs() < _dragWidth) {
            endPosition = beginPosition + _dragWidth;
          }
          int newBeginRange = uiRangeConverter(
            beginPosition,
            _dragWidth,
            _width - _dragWidth,
            0,
            filterSize.toDouble(),
          ).toInt();
          int newEndRange = uiRangeConverter(
            endPosition,
            _dragWidth,
            _width - _dragWidth,
            0,
            filterSize.toDouble(),
          ).toInt();
          if (newEndRange != endRange || newBeginRange != beginRange) {
            beginRange = newBeginRange;
            endRange = newEndRange;
            widget.onRangeChanged(beginRange, endRange);
          }
        },
        onHorizontalDragUpdate: (details) {
          endDragPosition = details.localPosition.dx;
          setState(() {
            if (beginDragPosition < endDragPosition) {
              beginPosition = beginDragPosition;
              endPosition = endDragPosition;
            } else {
              endPosition = beginDragPosition;
              beginPosition = endDragPosition;
            }
          });
        },
        child: Container(),
      ),
    );
  }

  Widget _selectedArea(BoxConstraints constraints) {
    return Positioned(
      left: beginPosition + _dragWidth,
      child: Obx(
        () => Visibility(
          visible: !widget.isReseted.value,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              int newBeginRange = uiRangeConverter(
                beginPosition,
                _dragWidth,
                _width - _dragWidth,
                0,
                filterSize.toDouble(),
              ).toInt();
              int newEndRange = uiRangeConverter(
                endPosition,
                _dragWidth,
                _width - _dragWidth,
                0,
                filterSize.toDouble(),
              ).toInt();
              if (newEndRange != endRange || newBeginRange != beginRange) {
                beginRange = newBeginRange;
                endRange = newEndRange;
                widget.onRangeChanged(beginRange, endRange);
              }
            },
            onHorizontalDragUpdate: (details) {
              final double delta = details.delta.dx;
              setState(() {
                double lastSelectedAreaWidth = selectedAreaWidth;
                beginPosition = beginPosition + delta;
                if (beginPosition < 0) {
                  beginPosition = 0;
                }
                if (beginPosition > _width - _dragWidth - selectedAreaWidth) {
                  beginPosition = _width - _dragWidth - selectedAreaWidth;
                }
                endPosition = beginPosition + lastSelectedAreaWidth;
                // if (beginPosition > endPosition - _dragWidth) {
                //   beginPosition = endPosition - _dragWidth;
                // }
              });
            },
            child: Container(
              height: constraints.maxHeight,
              width: (endPosition - beginPosition - _dragWidth >= 0)
                  ? endPosition - beginPosition - _dragWidth
                  : 0,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leftHanfler(BoxConstraints constraints) {
    return Positioned(
      left: beginPosition,
      top: 0,
      child: Obx(
        () => Visibility(
          visible: !widget.isReseted.value,
          child: Container(
            width: _dragWidth,
            height: constraints.maxHeight,
            alignment: Alignment.center,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                int newBeginRange = uiRangeConverter(
                  beginPosition,
                  _dragWidth,
                  _width - _dragWidth,
                  0,
                  filterSize.toDouble(),
                ).toInt();
                if (newBeginRange != beginRange) {
                  beginRange = newBeginRange;
                  widget.onRangeChanged(beginRange, endRange);
                }
              },
              onHorizontalDragUpdate: (details) {
                final double delta = details.delta.dx;
                setState(() {
                  beginPosition = beginPosition + delta;
                  if (beginPosition < 0) {
                    beginPosition = 0;
                  }
                  if (beginPosition > _width - _dragWidth) {
                    beginPosition = _width - _dragWidth;
                  }
                  if (beginPosition > endPosition - _dragWidth) {
                    beginPosition = endPosition - _dragWidth;
                  }
                });
              },
              child: Container(
                width: _dragWidth,
                height: 35,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: Color.fromRGBO(200, 200, 200, 1),
                ),
                child: Icon(
                  Icons.arrow_left_outlined,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rightHanfler(BoxConstraints constraints) {
    return Positioned(
      left: endPosition,
      top: 0,
      child: Obx(
        () => Visibility(
          visible: !widget.isReseted.value,
          child: Container(
            width: _dragWidth,
            height: constraints.maxHeight,
            alignment: Alignment.center,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                int newEndRange = uiRangeConverter(
                  endPosition,
                  _dragWidth,
                  _width - _dragWidth,
                  0,
                  filterSize.toDouble(),
                ).toInt();
                if (newEndRange != endRange) {
                  endRange = newEndRange;
                  widget.onRangeChanged(beginRange, endRange);
                }
              },
              onHorizontalDragUpdate: (details) {
                final double delta = details.delta.dx;
                setState(() {
                  endPosition = endPosition + delta;
                  if (endPosition < 0) {
                    endPosition = 0;
                  }
                  if (endPosition > _width - _dragWidth) {
                    endPosition = _width - _dragWidth;
                  }

                  if (endPosition < beginPosition + _dragWidth) {
                    endPosition = beginPosition + _dragWidth;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: Color.fromRGBO(200, 200, 200, 1),
                ),
                width: _dragWidth,
                height: 35,
                child: Icon(
                  Icons.arrow_right_outlined,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isInsideSelectedRange(int index) {
    if (index >= beginRange && index <= endRange) {
      return true;
    }
    return false;
  }
}
