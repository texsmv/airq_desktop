class StationModel {
  late int id;
  late String name;
  double? aqi;
  double? latitude;
  double? longitude;

  String get identifier => '$name - $id';

  late Map<String, List<DateTime>> annualDates;
  late Map<String, List<DateTime>> monthlyDates;

  StationModel(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude});

  StationModel.fromJson(data, Map annualDatesJson, Map monthlyDatesJson) {
    id = data['pk'];
    name = data['fields']['name'];
    latitude = data['fields']['latitude'];
    longitude = data['fields']['longitude'];

    if (latitude == -1) {
      latitude = null;
    }
    if (longitude == -1) {
      longitude = null;
    }

    List<String> keys = List<String>.from(annualDatesJson.keys.toList());
    annualDates = {};
    for (var i = 0; i < keys.length; i++) {
      annualDates[keys[i]] =
          List.generate(annualDatesJson[keys[i]].length, (index) {
        return DateTime.parse(annualDatesJson[keys[i]][index]);
      });
    }

    List<String> dkeys = List<String>.from(monthlyDatesJson.keys.toList());
    monthlyDates = {};
    for (var i = 0; i < dkeys.length; i++) {
      monthlyDates[keys[i]] =
          List.generate(monthlyDatesJson[keys[i]].length, (index) {
        return DateTime.parse(monthlyDatesJson[keys[i]][index]);
      });
    }
  }

  List<DateTime> get yearsRange {
    List<String> keys = List<String>.from(annualDates.keys.toList());
    List<DateTime> datetimes = [];
    // print(annualDates);
    for (var i = 0; i < keys.length; i++) {
      datetimes.addAll(annualDates[keys[i]]!);
    }
    datetimes.sort();
    if (datetimes.isEmpty) {
      return [];
    }
    return [datetimes.first, datetimes.last];
  }

  List<DateTime> get daysRange {
    List<String> keys = List<String>.from(monthlyDates.keys.toList());
    List<DateTime> datetimes = [];
    for (var i = 0; i < keys.length; i++) {
      datetimes.addAll(monthlyDates[keys[i]]!);
    }
    datetimes.sort();
    if (datetimes.isEmpty) {
      return [];
    }
    // TODO fix this
    return [datetimes.first, datetimes.last];
  }
}
