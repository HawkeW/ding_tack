import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:get/get.dart';
import 'package:tacktack/modules/tack.dart';
import 'package:uuid/v4.dart';

class TackPageController extends GetxController {
  Rx<TackMission> tackMission = TackMission(
    id: const UuidV4().toString(),
    leftTime: const Duration(minutes: 25),
    online: false,
    time: const Duration(minutes: 25),
  ).obs;

  TackMissionController tackController = TackMissionController(
    id: const UuidV4().toString(),
    leftTime: const Duration(minutes: 25),
    online: false,
    time: const Duration(minutes: 25),
  );

  bool get isTackRunning {
    return tackMission.value.startTime != null && tackMission.value.leftTime.inSeconds > 0;
  }

  bool get isTackPausing {
    return tackMission.value.pauseTime != null;
  }

  @override
  onInit() {
    super.onInit();
    tackController.addListener(() {
      tackMission.value = tackController.copyWith();
    });
  }

  createNewTack() {
    tackController = TackMissionController(
      id: const UuidV4().toString(),
      leftTime: const Duration(minutes: 25),
      online: false,
      time: const Duration(minutes: 25),
    );
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
    tackController.setTime(Duration(seconds: tackController.time.inSeconds - 300));
  }

  addMinutes() {
    tackController.setTime(Duration(seconds: tackController.time.inSeconds + 300));
  }
}

String formatNum(int data) {
  return data < 10? '0$data' : '$data';
}

String formatTime(Duration duration) {
  final hours = duration.inDays;
  final minutes = duration.inMinutes - 60 * hours;
  final seconds = duration.inSeconds - 60 * minutes;
  String display = "";
  if(hours > 0) display += '${formatNum(hours)}:';
  display += '${formatNum(minutes)}:${formatNum(seconds)}';
  return display;
}

class TackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: TackPageController(),
        builder: (controller) {
      return ScaffoldPage.withPadding(content: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: 180,
              height: 180,
              child: Stack(
                children: [
                  Positioned.fill(child: Obx(()=> ProgressRing( value: controller.tackMission.value.percent,))),
                  Positioned(child: Obx(()=> GestureDetector(
                    onTap: controller.showEditor,
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: Center(
                        child: Text(
                          '${formatTime(controller.tackMission.value.leftTime)} / ${formatTime(controller.tackMission.value.time)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  )),),
                  Positioned(child: Obx(()=> Opacity(opacity: controller.isShowEditor.isTrue ? 1 : 0, child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: Icon(Icons.keyboard_arrow_down, ), onPressed: controller.subMinutes),
                        IconButton(icon: Icon(Icons.keyboard_arrow_up), onPressed: controller.addMinutes),
                      ],
                    ),
                  ),)))
                ],
              )
            ),
            
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                children: [
                  Obx(()=> FilledButton(
                    onPressed: controller.isTackRunning ? controller.stopCurrentTack : controller.startCurrentTack,
                    child: controller.isTackRunning ?  const Text('结束', style: TextStyle(
                      decoration: TextDecoration.none,
                    ),) : const Text("开始", style: TextStyle(
                      decoration: TextDecoration.none,
                    ),),
                  )),
                  const SizedBox(height: 10,),
                  Obx(()=> FilledButton(
                    onPressed: controller.isTackPausing ? controller.continueCurrentTack : controller.pauseCurrentTack,
                    child: controller.isTackPausing ?  const Text('继续', style: TextStyle(
                      decoration: TextDecoration.none,
                    ),) : const Text("暂停", style: TextStyle(
                      decoration: TextDecoration.none,
                    ),),
                  )),
                ],
              ),
            )
          ],
        ),
      ));
    });
  }

}