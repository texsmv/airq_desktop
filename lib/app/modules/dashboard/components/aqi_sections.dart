import 'package:airq_ui/app/ui_utils.dart';
import 'package:flutter/material.dart';

List<AqiColor> _aqiSections = [
  AqiColor(
    color: const Color.fromRGBO(0, 228, 0, 1),
    minValue: 0,
    maxValue: 50,
  ),
  AqiColor(
    color: const Color.fromRGBO(255, 255, 0, 1),
    minValue: 50,
    maxValue: 100,
  ),
  AqiColor(
    color: const Color.fromRGBO(255, 126, 0, 1),
    minValue: 100,
    maxValue: 150,
  ),
  AqiColor(
    color: const Color.fromRGBO(255, 0, 0, 1),
    minValue: 150,
    maxValue: 200,
  ),
  AqiColor(
    color: const Color.fromRGBO(143, 63, 151, 1),
    minValue: 200,
    maxValue: 300,
  ),
  AqiColor(
    color: const Color.fromRGBO(126, 0, 35, 1),
    minValue: 300,
    maxValue: 500,
  ),
];

class AqiSections extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final Widget child;
  final bool showIaqi;
  const AqiSections({
    Key? key,
    required this.minValue,
    required this.maxValue,
    required this.child,
    required this.showIaqi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        children: [
          ...List.generate(
            _aqiSections.length,
            (index) => Positioned(
              bottom: uiRangeConverter(
                _aqiSections[index].minValue,
                0,
                500,
                0,
                maxValueHeight(constraints.maxHeight),
              ),
              child: Visibility(
                visible: showIaqi,
                child: Container(
                  height: uiRangeConverter(
                    _aqiSections[index].maxValue - _aqiSections[index].minValue,
                    0,
                    500,
                    0,
                    maxValueHeight(constraints.maxHeight),
                  ),
                  width: constraints.maxWidth,
                  color: _aqiSections[index].color.withOpacity(0.2),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  double maxValueHeight(double maxHeightConstraints) {
    return 500 * maxHeightConstraints / maxValue;
  }
}

class AqiColor {
  final double minValue;
  final double maxValue;
  final Color color;
  AqiColor({
    required this.maxValue,
    required this.minValue,
    required this.color,
  });
}
