import 'package:flutter/widgets.dart';

class PollutantModel {
  late int id;
  // late int datasetId;
  late String name;
  late Color color;
  double selectionRank = 0;

  PollutantModel({
    required this.id,
    // required this.datasetId,
    required this.name,
    required this.color,
  });
  PollutantModel.fromJson(data, Color sColor) {
    id = data['pk'];
    // datasetId = data['fields']['dataset'];
    name = data['fields']['name'];
    color = sColor;
  }

  // @override
  // bool operator ==(other) {
  //   if (other is! PollutantModel) {
  //     return false;
  //   }
  // return datasetId == other.datasetId;
  // }

  @override
  int get hashCode => id;
}
