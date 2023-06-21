import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/subset_controller.dart';

class SubsetView extends GetView<SubsetController> {
  const SubsetView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubsetView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SubsetView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
