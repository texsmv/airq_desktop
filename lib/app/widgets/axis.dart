import 'package:flutter/material.dart';

const double markSize = 7;
const double leftAxisNumbersSpacing = 40;
const double bottomAxisNumbersSpacing = 18;

class LeftAxis extends StatelessWidget {
  final double xMinValue;
  final double xMaxValue;
  final int xDivisions;
  final String xAxisLabel;
  final double yMinValue;
  final double yMaxValue;
  final int yDivisions;
  final String yAxisLabel;
  final Widget child;
  final List<String>? xLabels;
  const LeftAxis({
    Key? key,
    required this.xMinValue,
    required this.xMaxValue,
    required this.yMinValue,
    required this.yMaxValue,
    required this.xDivisions,
    required this.xAxisLabel,
    required this.yDivisions,
    required this.yAxisLabel,
    required this.child,
    this.xLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (_, constraints) => Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.only(
                left: leftAxisNumbersSpacing,
                bottom: bottomAxisNumbersSpacing,
              ),
              child: child,
            ),
            Positioned(
              left: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: bottomAxisNumbersSpacing,
                ),
                child: leftAxis(
                  constraints,
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: leftAxisNumbersSpacing,
                ),
                child: bottomAxis(
                  constraints,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomAxis(BoxConstraints constraints) {
    double axisWidth = constraints.maxWidth - leftAxisNumbersSpacing;
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        // color: Colors.grey,
        width: axisWidth,
        height: bottomAxisNumbersSpacing,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 1,
                  width: axisWidth,
                  color: Colors.black,
                ),
              ),
            ),
            ...List.generate(
              xDivisions,
              (index) => Positioned(
                left: index * (axisWidth / (xDivisions - 1)),
                top: 0,
                child: Container(
                  color: Colors.black,
                  height: markSize,
                  width: 2,
                ),
              ),
            ),
            ...List.generate(
              xDivisions,
              (index) => Positioned(
                left: index * (axisWidth / (xDivisions - 1)) - 20,
                top: markSize,
                child: Container(
                  // color: Colors.yellow,
                  width: 40,

                  alignment: Alignment.center,
                  child: Text(
                    xLabels == null
                        ? (((xMaxValue - xMinValue) / (xDivisions - 1) * index)
                            .toStringAsFixed(1))
                        : xLabels![index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -17,
              left: 0,
              child: Container(
                width: axisWidth,
                height: 17,
                // color: Colors.yellow,
                alignment: Alignment.center,
                child: Text(
                  xAxisLabel.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget leftAxis(BoxConstraints constraints) {
    double axisHeight = constraints.maxHeight - bottomAxisNumbersSpacing;
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        // color: Colors.grey,
        width: leftAxisNumbersSpacing,
        height: axisHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: axisHeight,
                  width: 1,
                  color: Colors.black,
                ),
              ),
            ),
            ...List.generate(
              yDivisions,
              (index) => Positioned(
                top: index * (axisHeight / (yDivisions - 1)),
                right: 0,
                child: Container(
                  color: Colors.black,
                  width: markSize,
                  height: 2,
                ),
              ),
            ),
            ...List.generate(
              yDivisions,
              (index) => Positioned(
                top: index * (axisHeight / (yDivisions - 1)) - 5,
                right: markSize,
                child: Text(
                  (yMaxValue -
                          (yMaxValue - yMinValue) / (yDivisions - 1) * index)
                      .toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -17,
              top: 0,
              child: Container(
                height: axisHeight,
                width: 17,
                // color: Colors.yellow,
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    yAxisLabel.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
