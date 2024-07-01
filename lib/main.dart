import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:get/get.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tacktack/pages/app_home.dart';
import 'package:window_manager/window_manager.dart';

import 'package:tacktack/pages/tack_page.dart';
import 'theme.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.showTitle();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(400, 600));
      await windowManager.setMinimumSize(const Size(400, 600));
      await windowManager.show();
      await windowManager.setPreventClose(false);
      await windowManager.setSkipTaskbar(false);

    });
  }
  runApp(const MyApp());
}
const String appTitle = 'Ding Tack';

class AppController extends GetxController {
  final appTheme = AppTheme().obs;
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
            init: AppController(),
            builder: (controller) {
          final appTheme = controller.appTheme.value;
          return AnimatedFluentTheme(
              data:  FluentThemeData(
                accentColor: appTheme.color,
                visualDensity: VisualDensity.standard,
                focusTheme: FocusThemeData(
                  glowFactor: is10footScreen(context) ? 2.0 : 0.0,
                ),
              ),
              child: GetMaterialApp(
                color: Colors.white,
                initialRoute: '/home',
                getPages: [
                  GetPage(name: '/home', page: () => const MyAppBody()),
                  GetPage(name: '/tack', page: () => TackPage()),
                ],
              )
          );
      },
    );
  }
}
