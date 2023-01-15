class DatasetModel {
  DatasetModel(
      {required this.name, required this.id, required this.pollutants});
  late String name;
  late int id;
  late List<String> pollutants;

  // DatasetModel.fromJson(dynamic data) {
  //   id = data['pk'];
  //   name = data['fields']['name'];
  // }
}
