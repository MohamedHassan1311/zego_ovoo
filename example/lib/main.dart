// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

import 'home_page.dart';

/// Here is the simplest demo.
///
/// Please follow the link below to see more details.
/// https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_audio_room_example_flutter



void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();
  ZegoUIKit().initLog().then((value) {
    runApp(MyApp(
      navigatorKey: navigatorKey,
    ));
  });
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
      navigatorKey: widget.navigatorKey,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            child!,
          ],
        );
      },
    );
  }
}
