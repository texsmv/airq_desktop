class DatasetModel {
  DatasetModel(
      {required this.name,
      required this.id,
      required this.pollutants,
      required this.allStations});
  late String name;
  late int id;
  late List<String> pollutants;
  late List<String> allStations;
}
