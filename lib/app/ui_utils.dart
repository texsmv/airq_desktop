import 'dart:core';
import 'dart:math';

import 'package:airq_ui/app/widgets/common/pbutton.dart';
import 'package:airq_ui/app/widgets/common/pdialog.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:random_color/random_color.dart';

import 'widgets/common/light_button.dart';

double std_min = -0.7;
double std_max = 0.7;

Map<String, List<double>> station_locations = {
  'Capão Redondo': [-23.6719026, -46.7794354],
  'Cerqueira César': [-23.0353135, -49.1650519],
  'Cid.Universitária-USP-Ipen': [-23.557594299316406, -46.71200180053711],
  'Congonhas': [-20.5015168, -43.8564586],
  'Ibirapuera': [-14.8428108, -40.8546285],
  'Interlagos': [-23.7019315, -46.6967078],
  'Itaim Paulista': [-23.5017648, -46.3996091],
  'Itaquera': [-23.5360799, -46.4555099],
  'Marg.Tietê-Pte Remédios': [-23.516924, -46.733631],
  'Mooca': [-23.5606808, -46.5971924],
  'N.Senhora do Ó': [-8.4720591, -35.0103062],
  'Osasco': [-8.399660110473633, -35.06126022338867],
  'Parelheiros': [-23.827312, -46.7277941],
  'Parque D.Pedro II': [-23.5508698, -46.6275136],
  'Pico do Jaraguá': [-23.4584254, -46.7670295],
  'Pinheiros': [-23.567249, -46.7019515],
  'Santana': [-12.979217, -44.05064],
  'Santo Amaro': [-12.5519686, -38.7060448],
  'Windsor Downtown': [42.315778, -83.043667],
  'Windsor West': [42.292889, -83.073139],
  'Chatham': [42.403694, -82.208306],
  'Sarnia': [42.990263, -82.395341],
  'Sarnia': [42.990263, -82.395341],
  'Grand Bend': [43.333083, -81.742889],
  'London': [42.97446, -81.200858],
  'London': [42.97446, -81.200858],
  'Port Stanley': [42.672083, -81.162889],
  'Tiverton': [44.314472, -81.549722],
  'Brantford': [43.138611, -80.292639],
  'Kitchener': [43.443833, -80.503806],
  'St. Catharines': [43.160056, -79.23475],
  'Guelph': [43.551611, -80.264167],
  'Hamilton Downtown': [43.257778, -79.861667],
  'Hamilton Mountain': [43.24132, -79.88941],
  'Hamilton West': [43.257444, -79.90775],
  'Hamilton Mountain': [43.24132, -79.88941],
  'Toronto Downtown': [43.662972, -79.388111],
  'Toronto East': [43.747917, -79.274056],
  'Toronto North': [43.78047, -79.467372],
  'Toronto North': [43.78047, -79.467372],
  'Toronto West': [43.709444, -79.5435],
  'Burlington': [43.315111, -79.802639],
  'Oakville': [43.486917, -79.702278],
  'Milton': [43.529650, -79.862449],
  'Oshawa': [43.95222, -78.9125],
  'Oshawa': [43.95222, -78.9125],
  'Brampton': [43.669911, -79.766589],
  'Brampton': [43.669911, -79.766589],
  'Mississauga': [43.54697, -79.65869],
  'Barrie': [44.382361, -79.702306],
  'Newmarket': [44.044306, -79.48325],
  'Parry Sound': [45.338261, -80.039269],
  'Dorset': [45.224278, -78.932944],
  'Ottawa Downtown': [45.434333, -75.676],
  'Ottawa Central': [45.382528, -75.714194],
  'Petawawa': [45.996722, -77.441194],
  'Kingston': [44.219722, -76.521111],
  'Kingston': [44.219722, -76.521111],
  'Belleville': [44.150528, -77.3955],
  'Morrisburg': [44.89975, -75.189944],
  'Cornwall': [45.017972, -74.735222],
  'Peterborough': [44.301917, -78.346222],
  'Thunder Bay': [48.379389, -89.290167],
  'Sault Ste. Marie': [46.533194, -84.309917],
  'North Bay': [46.322500, -79.4494444],
  'Sudbury': [46.49194, -81.003105],
  'Sudbury': [46.49194, -81.003105],
  'Merlin': [42.249526, -82.2180688],
  'Simcoe': [42.856834, -80.269722],
  'Stouffville': [43.964580, -79.266070],
  // HongKong stuff:
  'TAP MUN': [22.47739889541748, 114.36275530753716],
  'TAI PO': [22.448113324316108, 114.16586746973708],
  'NORTH': [22.50172748897659, 114.1285540488637],
  'YUEN LONG': [22.467372785923885, 114.02375890938951],
  'TUEN MUN': [22.39509752493444, 113.97929821572177],
  'TSUEN WAN': [22.380913023614593, 114.10483640411181],
  'SHA TIN': [22.39567098477031, 114.18670913567028],
  'KWAI CHUNG': [22.37406877003002, 114.11624896669262],
  'SHAM SHUI PO': [22.324581323126527, 114.15644103491213],
  'MONG KOK': [22.31882674036733, 114.15987674952666],
  'TUNG CHUNG': [22.282589394723665, 113.94520448629142],
  'CENTRAL': [22.2799590403546, 114.16612350337158],
  'CENTRAL/WESTERN': [22.28532988666009, 114.14269817645378],
  'SOUTHERN': [22.247376119378032, 114.16203384734007],
  'EASTERN': [22.283493002255888, 114.22174605856657],
  'CAUSEWAY BAY': [22.2798588997558, 114.1857213360911],
  'KWUN TONG': [22.305447811846236, 114.23013537749924],
  'TSEUNG KWAN O': [22.306836517257125, 114.26344590855533],
};

double uiRangeConverter(double oldValue, double oldMin, double oldMax,
    double newMin, double newMax) {
  return (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) +
      newMin;
}

Future<void> uiDelayed(VoidCallback callback,
    {Duration delay = const Duration(milliseconds: 250)}) async {
  await Future.delayed(delay);
  callback();
}

double uiEuclideanDistance(List<double> vectorA, List<double> vectorB) {
  assert(vectorA.length == vectorB.length);
  double distance = 0.0;
  for (int i = 0; i < vectorA.length; i++) {
    distance += pow(vectorA[i] - vectorB[i], 2);
  }
  return sqrt(distance);
}

void uiShowLoader() {
  Get.dialog(const Center(
    child: CircularProgressIndicator(),
  ));
}

void uiHideLoader() {
  Get.back();
}

Color uiClusterColor(String clusterId) {
  return Get.find<DatasetController>().clusterColors[clusterId]!;
}

bool uiIsIaqiAvailable(String pollName) {
  if (Get.find<DatasetController>().granularity == Granularity.annual) {
    return false;
  }
  return ['pm25', 'pm10', 'o3', 'no2', 'co'].contains(pollName.toLowerCase());
}

List<Color> colorList = [
  const Color.fromRGBO(2, 62, 138, 1),
  const Color.fromRGBO(251, 133, 0, 1),
  const Color.fromRGBO(255, 0, 109, 1),
  const Color.fromRGBO(2, 48, 71, 1),
  const Color.fromRGBO(33, 158, 188, 1),
  const Color.fromRGBO(45, 106, 79, 1),
  const Color.fromRGBO(214, 40, 40, 1),
  const Color.fromRGBO(112, 224, 0, 1),
  const Color.fromRGBO(255, 183, 3, 1),
  const Color.fromRGBO(131, 56, 236, 1),
  const Color.fromRGBO(119, 73, 54, 1),
];

Color uiGetColor(int index) {
  if (index < colorList.length) {
    return colorList[index];
  }
  RandomColor _randomColor = RandomColor();
  return _randomColor.randomColor();
}

List<Color> uiRangeColor(int length) {
  return List.generate(length,
      (index) => Color.fromRGBO(0, 0, ((255 / length) * index).toInt(), 1));
}

double uiPollutant2Aqi(double value, String pollutantName) {
  if (pollutantName == 'PM10' || pollutantName == 'MP10') {
    return pm10Iaqi(value);
  }
  if (pollutantName == 'PM25' || pollutantName == 'MP25') {
    return pm25Iaqi(value);
  }
  if (pollutantName == 'SO2') {
    return so2Iaqi(value);
  }
  if (pollutantName == 'CO') {
    return coIaqi(value);
  }
  if (pollutantName == 'NOx') {
    return noxIaqi(value);
  }
  if (pollutantName == 'O3') {
    return o3Iaqi(value);
  }
  return -1;
}

bool uiHasIaqi(String pollutantName) {
  return uiPollutant2Aqi(0, pollutantName) != -1;
}

double pm25Iaqi(double x) {
  if (x <= 30) {
    return x * 50 / 30;
  } else if (x <= 60) {
    return 50 + (x - 30) * 50 / 30;
  } else if (x <= 90) {
    return 100 + (x - 60) * 100 / 30;
  } else if (x <= 120) {
    return 200 + (x - 90) * 100 / 30;
  } else if (x <= 250) {
    return 300 + (x - 120) * 100 / 130;
  } else if (x > 250) {
    return 400 + (x - 250) * 100 / 130;
  } else {
    return 0;
  }
}

double pm10Iaqi(double x) {
  if (x <= 50) {
    return x;
  } else if (x <= 100) {
    return x;
  } else if (x <= 250) {
    return 100 + (x - 100) * 100 / 150;
  } else if (x <= 350) {
    return 200 + (x - 250);
  } else if (x <= 430) {
    return 300 + (x - 350) * 100 / 80;
  } else if (x > 430) {
    return 400 + (x - 430) * 100 / 80;
  } else {
    return 0;
  }
}

double so2Iaqi(double x) {
  if (x <= 40) {
    return x * 50 / 40;
  } else if (x <= 80) {
    return 50 + (x - 40) * 50 / 40;
  } else if (x <= 380) {
    return 100 + (x - 80) * 100 / 300;
  } else if (x <= 800) {
    return 200 + (x - 380) * 100 / 420;
  } else if (x <= 1600) {
    return 300 + (x - 800) * 100 / 800;
  } else if (x > 1600) {
    return 400 + (x - 1600) * 100 / 800;
  } else {
    return 0;
  }
}

double noxIaqi(double x) {
  if (x <= 40) {
    return x * 50 / 40;
  } else if (x <= 80) {
    return 50 + (x - 40) * 50 / 40;
  } else if (x <= 180) {
    return 100 + (x - 80) * 100 / 100;
  } else if (x <= 280) {
    return 200 + (x - 180) * 100 / 100;
  } else if (x <= 400) {
    return 300 + (x - 280) * 100 / 120;
  } else if (x > 400) {
    return 400 + (x - 400) * 100 / 120;
  } else {
    return 0;
  }
}

double coIaqi(double x) {
  if (x <= 1) {
    return x * 50 / 1;
  } else if (x <= 2) {
    return 50 + (x - 1) * 50 / 1;
  } else if (x <= 10) {
    return 100 + (x - 2) * 100 / 8;
  } else if (x <= 17) {
    return 200 + (x - 10) * 100 / 7;
  } else if (x <= 34) {
    return 300 + (x - 17) * 100 / 17;
  } else if (x > 34) {
    return 400 + (x - 34) * 100 / 17;
  } else {
    return 0;
  }
}

double o3Iaqi(double x) {
  // if (x <= 50) {
  //   return x * 50 / 50;
  // } else if (x <= 100) {
  //   return 50 + (x - 50) * 50 / 50;
  // } else if (x <= 168) {
  //   return 100 + (x - 100) * 100 / 68;
  // } else if (x <= 208) {
  //   return 200 + (x - 168) * 100 / 40;
  // } else if (x <= 748) {
  //   return 300 + (x - 208) * 100 / 539;
  // } else if (x > 748) {
  //   return 400 + (x - 400) * 100 / 539;
  // } else {
  //   return 0;
  // }

  if (x <= 0.54) {
    return x * 50 / 0.54;
  } else if (x <= 100) {
    return 50 + (x - 50) * 50 / 50;
  } else if (x <= 168) {
    return 100 + (x - 100) * 100 / 68;
  } else if (x <= 208) {
    return 200 + (x - 168) * 100 / 40;
  } else if (x <= 748) {
    return 300 + (x - 208) * 100 / 539;
  } else if (x > 748) {
    return 400 + (x - 400) * 100 / 539;
  } else {
    return 0;
  }
}

List<double> uiStationCoordinates(String name) {
  List<double>? coords = station_locations[name];
  if (coords == null) {
    print('$name not found');
    return [0, 0];
  }

  return station_locations[name]!;
}

String uiMonthNameByIndex(int num) {
  int pos = num - 1;
  switch (pos) {
    case 0:
      return 'January';
    case 1:
      return 'February';
    case 2:
      return 'March';
    case 3:
      return 'April';
    case 4:
      return 'May';
    case 5:
      return 'June';
    case 6:
      return 'July';
    case 7:
      return 'August';
    case 8:
      return 'September';
    case 9:
      return 'October';
    case 10:
      return 'November';
    case 11:
      return 'December';
  }
  return 'none';
}

Future<int> uiPickNumberInt(int minValue, int maxValue,
    {int? defaultValue}) async {
  late RxInt currentValue;
  if (defaultValue != null) {
    currentValue = defaultValue.obs;
  } else {
    currentValue = minValue.obs;
  }

  return await Get.dialog(
    PDialog(
      height: 300,
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(
            () => NumberPicker(
              value: currentValue.value,
              minValue: 0,
              maxValue: 100,
              onChanged: (value) {
                currentValue.value = value;
              },
            ),
          ),
          PButton(
            text: 'Accept',
            onTap: () {
              Get.back(result: currentValue.value);
            },
          )
        ],
      ),
    ),
  );
}

Future<String> uiPickString({String? defaultValue}) async {
  late String currentValue;
  if (defaultValue != null) {
    currentValue = defaultValue;
  } else {
    currentValue = 'image';
  }

  return await Get.dialog(
    PDialog(
      height: 200,
      width: 300,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextField(
              onChanged: (value) {
                currentValue = value;
              },
            ),
            PButton(
              text: 'Accept',
              onTap: () {
                if (currentValue.isNotEmpty) {
                  Get.back(result: currentValue);
                } else {
                  Get.snackbar('Error', 'Insert a name');
                }
              },
            )
          ],
        ),
      ),
    ),
  );
}

String uiWeekDayStr(int day) {
  switch (day) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';

    default:
      return '';
  }
}
