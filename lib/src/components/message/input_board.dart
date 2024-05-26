// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/message/view.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_audio_room/src/inner_text.dart';

import '../../../zego_uikit_prebuilt_live_audio_room.dart';

/// @nodoc
class ZegoLiveAudioRoomInRoomMessageInputBoard extends ModalRoute<String> {
  ZegoLiveAudioRoomInRoomMessageInputBoard({
    required this.innerText,required this.inRoomMessage, this.avatarBuilder,
    this.rootNavigator = false,
  }) : super();

  final ZegoUIKitPrebuiltLiveAudioRoomInnerText innerText;
  final ZegoLiveAudioRoomInRoomMessageConfig inRoomMessage;
  final ZegoAvatarBuilder? avatarBuilder;
  final bool rootNavigator;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => ZegoUIKitDefaultTheme.viewBarrierColor;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[

          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(
                context,
                rootNavigator: rootNavigator,
              ).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          ZegoLiveAudioRoomInRoomLiveMessageView(
            config: inRoomMessage,
            avatarBuilder: avatarBuilder,
          ),
          ZegoInRoomMessageInput(
            placeHolder: innerText.messageEmptyToast,
            backgroundColor: Colors.white,
            inputBackgroundColor: const Color(0xffF7F7F8),
            textColor: const Color(0xff1B1B1B),
            textHintColor: const Color(0xff1B1B1B).withOpacity(0.5),
            buttonColor: const Color(0xff834D3D),
            onSubmit: () {
              // Navigator.of(
              //   context,
              //   rootNavigator: rootNavigator,
              // ).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}
