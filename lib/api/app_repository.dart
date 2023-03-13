import 'dart:convert';
import 'dart:math';

import 'package:airq_ui/app/list_shape_ext.dart';
import 'package:airq_ui/models/dataset_model.dart';
import 'package:http/http.dart';

import 'api_config.dart';

Future<List<DatasetModel>> repositoryDatasets() async {
  final response = await post(Uri.parse("${hostUrl}datasets"));
  dynamic data = await jsonDecode(response.body);

  List<DatasetModel> datasets = [];
  int counter = 0;
  for (var key in data.keys) {
    List<String> pollutants = List<String>.from(data[key]['pollutants']);
    // print(data[key]['pollutants']);
    DatasetModel dataset =
        DatasetModel(id: counter, name: key, pollutants: pollutants);
    datasets.add(dataset);

    counter += 1;
  }
  return datasets;
}

Future<Map<int, List<double>>> repositoryContrastiveFeatures(
    List<int> classes) async {
  final response = await post(
    Uri.parse("${hostUrl}getContrastiveFeatures"),
    body: {
      'classes': jsonEncode(classes),
    },
  );

  dynamic data = jsonDecode(response.body);
  List<String> clustKeys = List<String>.from(data.keys);

  Map<int, List<double>> mapRes = {};
  for (var i = 0; i < clustKeys.length; i++) {
    mapRes[int.parse(clustKeys[i])] = List<double>.from((data[clustKeys[i]]));
  }
  return mapRes;
}

Future<Map<String, dynamic>> repositoryLoadDataset(
  String dataset,
  String granularity,
  List<String> pollutants,
  int smoothWindow,
  bool normalize,
) async {
  final response = await post(
    Uri.parse("${hostUrl}loadWindows"),
    body: {
      'dataset': dataset,
      'granularity': granularity,
      'pollutants': jsonEncode(pollutants),
      'smoothWindow': smoothWindow.toString(),
      'shapeNorm': normalize.toString(),
    },
  );

  dynamic data = await jsonDecode(response.body);
  return data;
}

Future<Map<String, List<dynamic>>> repositoryCorrelationMatrix(
  List<int> positions,
) async {
  final response = await post(
    Uri.parse("${hostUrl}correlation"),
    body: {
      'positions': jsonEncode(positions),
    },
  );

  dynamic data = await jsonDecode(response.body);

  List<dynamic> corrArray = data['correlation_matrix'];
  int matSize = sqrt(corrArray.length.toDouble()).toInt();
  List<dynamic> corrMatrix = corrArray.reshape([matSize, matSize]);

  List<dynamic> coords = jsonDecode(response.body)['coords'];
  coords = coords.reshape([(coords.length / 2).floor(), 2]);

  return {
    'corrMatrix': corrMatrix,
    'coords': coords,
  };
}

Future<List<int>> repositoryClustering(int n_clusters) async {
  final response = await post(Uri.parse("${hostUrl}kmeans"), body: {
    'n_clusters': jsonEncode(n_clusters),
  });

  dynamic data = jsonDecode(response.body);
  List<int> classes = List<int>.from(data['classes']);
  return classes;
}

Future<List<dynamic>> repositoryGetProjection({
  required double delta,
  required double beta,
  required List<int> pollutantPositions,
  int neighbors = 15,
}) async {
  final response = await post(
    Uri.parse("${hostUrl}getProjection"),
    body: {
      'pollutantsPositions': jsonEncode(pollutantPositions),
      'neighbors': jsonEncode(neighbors),
      'delta': delta,
      'beta': beta
    },
  );

  List<dynamic> coords = jsonDecode(response.body)['coords'];
  coords = coords.reshape([(coords.length / 2).floor(), 2]);

  return coords;
}

Future<List<dynamic>> repositoryGetFdaOutliers(int pos) async {
  final response = await post(
    Uri.parse("${hostUrl}getFdaOutliers"),
    body: {
      'pollutantPosition': pos.toString(),
    },
  );

  dynamic data = jsonDecode(response.body);

  List<dynamic> cmean = data['cmean'];
  List<dynamic> cvar = data['cvar'];
  List<dynamic> coords = [cmean, cvar];

  return coords;
}
