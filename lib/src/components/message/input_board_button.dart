// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/message/input_board.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/inner_text.dart';

import '../../../zego_uikit_prebuilt_live_audio_room.dart';

/// @nodoc
class ZegoLiveAudioRoomInRoomMessageInputBoardButton extends StatefulWidget {
  final Size? iconSize;
  final Size? buttonSize;
  final ZegoUIKitPrebuiltLiveAudioRoomInnerText innerText;
  final bool rootNavigator;
  final ZegoLiveAudioRoomInRoomMessageConfig inRoomMessage;
  final ZegoAvatarBuilder? avatarBuilder;

  final Function(int)? onSheetPopUp;
  final Function(int)? onSheetPop;

  const ZegoLiveAudioRoomInRoomMessageInputBoardButton({
    Key? key,
    required this.innerText,
    this.rootNavigator = false,
    this.iconSize,
    this.buttonSize,
    this.onSheetPopUp,
    this.onSheetPop, required this.inRoomMessage, this.avatarBuilder,
  }) : super(key: key);

  @override
  State<ZegoLiveAudioRoomInRoomMessageInputBoardButton> createState() =>
      _ZegoLiveAudioRoomInRoomMessageInputBoardButtonState();
}

/// @nodoc
class _ZegoLiveAudioRoomInRoomMessageInputBoardButtonState
    extends State<ZegoLiveAudioRoomInRoomMessageInputBoardButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(

      onPressed: () {
        final key = DateTime.now().millisecondsSinceEpoch;
        widget.onSheetPopUp?.call(key);

        Navigator.of(
          context,
          rootNavigator: widget.rootNavigator,
        )
            .push(
          ZegoLiveAudioRoomInRoomMessageInputBoard(
            innerText: widget.innerText,
            rootNavigator: widget.rootNavigator, inRoomMessage: widget.inRoomMessage,
            avatarBuilder: widget.avatarBuilder
          ),
        )
            .then((value) {
          widget.onSheetPop?.call(key);
        });
      },
      icon: ButtonIcon(
        icon: ZegoLiveAudioRoomImage.asset(ZegoLiveAudioRoomIconUrls.im,
        color: Colors.white,
          scale: .8
        ),
        backgroundColor: Colors.white.withOpacity(.2)
      ),
      iconSize: widget.iconSize ?? Size(72.zR, 72.zR),
      buttonSize: widget.buttonSize ?? Size(96.zR, 96.zR),
    );
  }
}
