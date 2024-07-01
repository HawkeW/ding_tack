import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:get/get.dart';
import 'package:tacktack/modules/tack.dart';
import 'package:uuid/v4.dart';

import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

class TackPageController extends GetxController {
  Rx<TackMission> tackMission = TackMission(
    id: "",
    runTime: const Duration(minutes: 0),
    online: false,
    time: const Duration(minutes: 0),
  ).obs;

  late TackMissionController tackController;

  bool get isTackRunning {
    return tackMission.value.isRunning;
  }

  bool get isTackPausing {
    return tackMission.value.isPausing;
  }

  bool get isTackCompleted {
    return tackMission.value.isCompleted;
  }

  @override
  onInit() {
    super.onInit();
    createNewTack();
  }

  createNewTack() {
    tackController = TackMissionController(
      id: const UuidV4().toString(),
      runTime: const Duration(seconds: 0),
      online: false,
      time: const Duration(minutes: 25),
    );
    tackMission.value = tackController.copyWith();
    tackController.addListener(() {
      tackMission.value = tackController.copyWith();
      if (tackMission.value.isCompleted) {
        sendNotification();

        createNewTack();
      }
    });
  }

  startCurrentTack() {
    tackController.startTo();
  }

  stopCurrentTack() {
    tackController.stopTo();
  }

  continueCurrentTack() {
    tackController.continueTo();
  }

  pauseCurrentTack() {
    tackController.pauseTo();
  }

  RxBool isShowEditor = false.obs;

  showEditor() {
    isShowEditor.value = !isShowEditor.value;
  }

  subMinutes() {
    tackController.addTime(const Duration(seconds: -300));
  }

  addMinutes() {
    tackController.addTime(const Duration(seconds: 300));
  }

  sendNotification() {
    // Create an instance of Windows Notification with your application name
    // application id must be null in packaged mode
    final winNotifyPlugin = WindowsNotification(
        applicationId:
            r"com.oncew.dingtack_fxkeb4dgdm144!tacktack");

    // create new NotificationMessage instance with id, title, body, and images
    NotificationMessage message = NotificationMessage.fromPluginTemplate(
      "Ding Tack",
      "Tack Tack!",
      "时钟结束啦~去休息一下吧！",
    );

    // show notification
    winNotifyPlugin.showNotificationPluginTemplate(message);
  }
}

String formatNum(int data) {
  return data < 10 ? '0$data' : '$data';
}

String formatTime(Duration duration) {
  final hours = duration.inDays;
  final minutes = duration.inMinutes - 60 * hours;
  final seconds = duration.inSeconds - 60 * minutes;
  String display = "";
  if (hours > 0) display += '${formatNum(hours)}:';
  display += '${formatNum(minutes)}:${formatNum(seconds)}';
  return display;
}

class TackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: TackPageController(),
        builder: (controller) {
          return ScaffoldPage.withPadding(
              content: Center(
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    width: 180,
                    height: 180,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: Obx(() => ProgressRing(
                                  value: controller.tackMission.value.percent,
                                ))),
                        Positioned(
                          child: Obx(() => GestureDetector(
                                onTap: controller.showEditor,
                                child: SizedBox(
                                  height: 180,
                                  width: 180,
                                  child: Center(
                                    child: Text(
                                      formatTime(controller
                                          .tackMission.value.leftTime),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 20,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                        Positioned(
                            child: Obx(() => Opacity(
                                  opacity:
                                      controller.isShowEditor.isTrue ? 1 : 0,
                                  child: SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.keyboard_arrow_down,
                                            ),
                                            onPressed:
                                                controller.isShowEditor.isTrue
                                                    ? controller.subMinutes
                                                    : null),
                                        IconButton(
                                            icon: Icon(Icons.keyboard_arrow_up),
                                            onPressed:
                                                controller.isShowEditor.isTrue
                                                    ? controller.addMinutes
                                                    : null),
                                      ],
                                    ),
                                  ),
                                )))
                      ],
                    )),
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Obx(() => FilledButton(
                            onPressed: controller.isTackCompleted
                                ? null
                                : controller.isTackRunning
                                    ? controller.stopCurrentTack
                                    : controller.startCurrentTack,
                            child: controller.isTackRunning
                                ? const Text(
                                    '结束',
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  )
                                : const Text(
                                    "开始",
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() => FilledButton(
                            onPressed: controller.isTackCompleted
                                ? null
                                : controller.isTackPausing
                                    ? controller.continueCurrentTack
                                    : controller.pauseCurrentTack,
                            child: controller.isTackPausing
                                ? const Text(
                                    '继续',
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  )
                                : const Text(
                                    "暂停",
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                        Obx(() => FilledButton(
                        onPressed: controller.isTackRunning
                            ? null
                            : controller.createNewTack,
                        child: const Text(
                          "新建",
                          style: TextStyle(
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ))
                    ],
                  ),
                )
              ],
            ),
          ));
        });
  }
}
