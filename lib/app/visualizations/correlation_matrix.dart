import 'package:flutter/material.dart';
import 'package:rainbow_color/rainbow_color.dart';

class CorrelationMatrix extends StatefulWidget {
  final List<dynamic> matrix;
  final List<String> names;
  const CorrelationMatrix({
    Key? key,
    required this.matrix,
    required this.names,
  }) : super(key: key);

  @override
  State<CorrelationMatrix> createState() => _CorrelationMatrixState();
}

class _CorrelationMatrixState extends State<CorrelationMatrix> {
  int get n => widget.matrix.length;
  late double blockSize;
  late double namesHeight;

  Rainbow rb = Rainbow(
      spectrum: [Colors.red, Colors.white, Colors.blue],
      rangeStart: -1,
      rangeEnd: 1);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraints) {
      namesHeight = contraints.maxHeight * 0.05;
      blockSize = (contraints.maxHeight - namesHeight) / n;
      var math;
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          Container(
            height: namesHeight,
            width: double.infinity,
            padding: EdgeInsets.only(left: namesHeight),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                n,
                (index) => Container(
                  width: blockSize,
                  // decoration: BoxDecoration(border: Border.all()),
                  alignment: Alignment.center,
                  child: Text(widget.names[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ),
          ),
          ...List.generate(
            n,
            (i) => Row(
              children: [
                Container(
                  width: namesHeight,
                  height: blockSize,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(widget.names[i],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ),
                ...List.generate(
                  i + 1,
                  (j) => Container(
                    width: blockSize,
                    height: blockSize,
                    padding: EdgeInsets.all(blockSize * 0.3),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black)),
                    // child: Text(widget.matrix[i][j].toString()),
                    child: LayoutBuilder(
                      builder: (c, boxConst) => Center(
                        child: Container(
                          width: boxConst.maxWidth * widget.matrix[i][j].abs(),
                          height:
                              boxConst.maxHeight * widget.matrix[i][j].abs(),
                          decoration: BoxDecoration(
                              color: rb[widget.matrix[i][j]],
                              shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
    });
  }
}
