import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/constants/constants.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/routes/app_pages.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_controller.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double barWidth = 70;

class PBar extends StatefulWidget {
  final List<ActionButton> actions;
  PBar({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  State<PBar> createState() => _PBarState();
}

class _PBarState extends State<PBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: pCardSpace,
        bottom: pCardSpace,
        left: pCardSpace,
      ),
      child: Container(
        width: barWidth,
        height: double.infinity,
        decoration: BoxDecoration(
          color: pColorBackground,
          borderRadius: BorderRadius.circular(barWidth / 3),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              itemCount: widget.actions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (c, index) {
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      widget.actions[index].onTap();
                    },
                    child: Card(
                      elevation: 1,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.actions[index].selected
                              ? pColorAccent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Image(
                            image: AssetImage(widget.actions[index].icon),
                            height: 25,
                            width: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                await Get.delete<DatasetController>(force: true);
                await Get.put(DatasetController(), permanent: true);

                Get.offAllNamed(Routes.SPLASH);
                Future.delayed(Duration(seconds: 3)).then((value) {
                  Get.delete<IProjectionController>(tag: 'global');
                  Get.delete<IProjectionController>(tag: 'local');
                  // Get.delete<IProjectionController>(tag: 'filter');
                  // Get.delete<IProjectionController>(tag: 'outlier');
                  Get.delete<DashboardController>();
                });
              },
              icon: const Icon(
                Icons.exit_to_app,
                size: 25,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ActionButton {
  String icon;
  Function onTap;
  bool selected;
  ActionButton({
    required this.icon,
    required this.onTap,
    required this.selected,
  });
}
