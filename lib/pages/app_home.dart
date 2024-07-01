import 'dart:io';

import 'package:flutter/material.dart' show Scaffold;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:tacktack/pages/tack_page.dart';

import '../widgets/window_title_bar/window_title.dart';

class MyAppBody extends StatefulWidget {
  const MyAppBody({super.key});

  @override
  MyAppBodyState createState() => MyAppBodyState();
}

class MyAppBodyState extends State<MyAppBody> {
  WindowEffect effect = WindowEffect.acrylic;
  Color color = Platform.isWindows ? const Color(0xCCffffff) : Colors.transparent;
  InterfaceBrightness brightness =
  Platform.isMacOS ? InterfaceBrightness.auto : InterfaceBrightness.light;
  MacOSBlurViewState macOSBlurViewState =
      MacOSBlurViewState.followsWindowActiveState;

  @override
  void initState() {
    super.initState();
    setWindowEffect(effect);
  }

  void setWindowEffect(WindowEffect? value) {
    Window.setEffect(
      effect: value!,
      color: color,
      dark: brightness == InterfaceBrightness.dark,
    );
    if (Platform.isMacOS) {
      if (brightness != InterfaceBrightness.auto) {
        Window.overrideMacOSBrightness(
          dark: brightness == InterfaceBrightness.dark,
        );
      }
    }
    setState(() => effect = value);
  }

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child:  Stack(
        children: [
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WindowTitleBar(
                  brightness: brightness,
                ),
                Expanded(
                  child: TackPage(),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
