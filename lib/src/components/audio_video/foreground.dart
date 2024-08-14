// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/audio_video/audio_room_layout.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/audio_video/defines.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/components/pop_up_sheet_menu.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/config.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/core/seat/seat_manager.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/src/events.dart';

/// @nodoc
class ZegoLiveAudioRoomSeatForeground extends StatefulWidget {
  final Size size;
  final ZegoUIKitUser? user;
  final Map<String, dynamic> extraInfo;

  final ZegoLiveAudioRoomSeatManager seatManager;
  final ZegoLiveAudioRoomConnectManager connectManager;
  final ZegoLiveAudioRoomPopUpManager popUpManager;
  final ZegoUIKitPrebuiltLiveAudioRoomConfig config;
  final ZegoUIKitPrebuiltLiveAudioRoomEvents events;
  final ZegoUIKitPrebuiltLiveAudioRoomController? prebuiltController;

  const ZegoLiveAudioRoomSeatForeground({
    Key? key,
    this.user,
    this.extraInfo = const {},
    this.prebuiltController,
    required this.size,
    required this.seatManager,
    required this.connectManager,
    required this.popUpManager,
    required this.config,
    required this.events,
  }) : super(key: key);

  @override
  State<ZegoLiveAudioRoomSeatForeground> createState() =>
      _ZegoLiveAudioRoomSeatForegroundState();
}

/// @nodoc
class _ZegoLiveAudioRoomSeatForegroundState
    extends State<ZegoLiveAudioRoomSeatForeground> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClicked,
      onDoubleTap: onDoubleClicked,
      child:widget.config.seat.foregroundCustomWidget??  Stack(
        children: [
          Container(
            color: Colors.transparent,
            child: foreground(
              context,
              widget.size,
              ZegoUIKit().getUser(widget.user?.id ?? ''),
              widget.extraInfo,
            ),
          ),
          if (widget.user != null && widget.user!.microphone.value == true)
            Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKitPrebuiltLiveAudioRoomController()
                    .seat
                    .muteStateNotifier(
                        ZegoUIKitPrebuiltLiveAudioRoomController()
                            .seat
                            .getSeatIndexByUserID(
                              widget.user!.id!,
                            ),
                        isLocally: true),
                builder: (context, isMuted, _) {
                  return isMuted
                      ? Container(
                          width: seatIconWidth * 1.20,
                          height: seatIconHeight * 1.15,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black54),
                          child: Icon(
                            Icons.volume_off,
                            color: Colors.white,
                          ),
                        )
                      : SizedBox();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget foreground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Column
                (
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  userName(context, constraints.maxWidth),
                  if (widget.user != null)
                    StreamBuilder(
                        stream: widget.config.seat.attractiveCount,
                        builder: (context, snap) {
                          if (snap.hasData) {
                            final data = snap.data as Map<String, dynamic>;
                            if (snap.hasData && data["id"] == widget.user!.id) {
                              return userAttractive(
                                  data["count"], constraints.maxWidth);
                            } else {
                              return SizedBox();
                            }
                          } else {
                            return userAttractive(
                                null, constraints.maxWidth);
                          }
                        })
                ],
              ),
            ),
            // if (widget.seatManager.isAttributeHost(user))
            //   Positioned(
            //     top: seatItemHeight - seatUserNameFontSize - 3.zR, //  spacing
            //     child: hostFlag(context, constraints.maxWidth),
            //   ),
            //
            // if (widget.seatManager.isCoHost(user))
            //   Positioned(
            //     top: seatItemHeight -
            //         seatUserNameFontSize -
            //         // seatHostFlagHeight -
            //         3.zR, //  spacing
            //     child: coHostFlag(context, constraints.maxWidth),
            //   )
            // ,
            ...null == widget.user ? [] : [microphoneOffFlag()],
          ],
        );
      },
    );
  }

  void onDoubleClicked() {
    final index =
        int.tryParse(widget.extraInfo[layoutGridItemIndexKey].toString()) ?? -1;
    if (-1 == index) {
      ZegoLoggerService.logInfo(
        'ERROR!!! click seat index is invalid',
        tag: 'audio room',
        subTag: 'foreground',
      );
      return;
    }

    if (widget.events.seat.onDoubleClicked != null) {
      ZegoLoggerService.logInfo(
        'ERROR!!! click seat event is deal outside',
        tag: 'audio room',
        subTag: 'foreground',
      );

      widget.events.seat.onDoubleClicked!.call(index, widget.user);
      return;
    }

    final popupItems = <ZegoLiveAudioRoomPopupItem>[];

    if (null == widget.user) {
      /// empty seat
      /// forbid host switch seat and speaker/audience take locked seat
      if (!widget.seatManager.localIsAHost &&
          !widget.seatManager.isAHostSeat(index)) {
        if (-1 !=
            widget.seatManager
                .getIndexByUserID(ZegoUIKit().getLocalUser().id)) {
          /// local user is on seat
          widget.seatManager.switchToSeat(index);
        } else {
          /// local user is not on seat
          if (!widget.seatManager.lockedSeatNotifier.value.contains(index)) {
            /// only room seat is not locked and index is not in locked seats
            /// if locked, can't apply by click seat
            popupItems.add(ZegoLiveAudioRoomPopupItem(
              ZegoLiveAudioRoomPopupItemValue.takeOnSeat,
              widget.config.innerText.takeSeatMenuButton,
              data: index,
            ));
          }
        }
      }
    } else {
      /// have a user on seat
      if (widget.seatManager.localHasHostPermissions &&
          widget.user?.id != ZegoUIKit().getLocalUser().id) {
        /// local is host, click others
        popupItems

          /// host can kick others off seat
          ..add(ZegoLiveAudioRoomPopupItem(
            ZegoLiveAudioRoomPopupItemValue.takeOffSeat,
            widget.config.innerText.removeSpeakerMenuDialogButton.replaceFirst(
              widget.config.innerText.param_1,
              RegExp(r'^(.*?)\s*CC').firstMatch( widget.user!.name )?.group(1)??   widget.user?.name ?? '',
            ),
            data: index,
          ))

          /// host can mute others
          ..add(ZegoLiveAudioRoomPopupItem(
            ZegoLiveAudioRoomPopupItemValue.muteSeat,
            widget.config.innerText.muteSpeakerMenuDialogButton.replaceFirst(
              widget.config.innerText.param_1,
              RegExp(r'^(.*?)\s*CC').firstMatch( widget.user!.name )?.group(1)??     widget.user?.name ?? '',
            ),
            data: index,
          ));

        if (widget.seatManager.localIsAHost) {
          ///
          // popupItems.add(PopupItem(
          //   PopupItemValue.kickOut,
          //   widget.config.innerText.removeUserMenuDialogButton.replaceFirst(
          //     widget.config.innerText.param_1,
          //     widget.user?.name ?? '',
          //   ),
          //   data: widget.user?.id ?? '',
          // ));

          /// only support by host
          if (widget.seatManager.isCoHost(widget.user)) {
            /// host revoke a co-host
            popupItems.add(ZegoLiveAudioRoomPopupItem(
              ZegoLiveAudioRoomPopupItemValue.revokeCoHost,
              widget.config.innerText.revokeCoHostPrivilegesMenuDialogButton
                  .replaceFirst(
                widget.config.innerText.param_1,
                RegExp(r'^(.*?)\s*CC').firstMatch(widget.user!.name)?.group(1) ?? widget.user?.name ?? '',
              ),
              data: widget.user?.id ?? '',
            ));
          } else if (widget.seatManager.isSpeaker(widget.user)) {
            /// host can specify one speaker be a co-host if no co-host now
            popupItems.add(ZegoLiveAudioRoomPopupItem(
              ZegoLiveAudioRoomPopupItemValue.assignCoHost,
              widget.config.innerText.assignAsCoHostMenuDialogButton
                  .replaceFirst(
                widget.config.innerText.param_1,

                RegExp(r'^(.*?)\s*CC').firstMatch(widget.user!.name)?.group(1) ?? widget.user?.name ?? '',
              ),
              data: widget.user?.id ?? '',
            ));
          }
        }
      } else if (ZegoUIKit().getLocalUser().id ==
              widget.seatManager.getUserByIndex(index)?.id &&
          ZegoLiveAudioRoomRole.host != widget.seatManager.localRole.value) {
        /// local is not a host, kick self

        /// speaker can local leave seat
        popupItems.add(ZegoLiveAudioRoomPopupItem(
          ZegoLiveAudioRoomPopupItemValue.leaveSeat,
          widget.config.innerText.leaveSeatDialogInfo.title,
        ));
      }
    }

    if (popupItems.isEmpty) {
      return;
    }

    popupItems.add(ZegoLiveAudioRoomPopupItem(
      ZegoLiveAudioRoomPopupItemValue.cancel,
      widget.config.innerText.cancelMenuDialogButton,
    ));

    showPopUpSheet(
      context: context,
      userID: widget.user?.id ?? '',
      popupItems: popupItems,
      seatManager: widget.seatManager,
      connectManager: widget.connectManager,
      popUpManager: widget.popUpManager,
      innerText: widget.config.innerText,
    );
  }

  void onClicked() {
    final index =
        int.tryParse(widget.extraInfo[layoutGridItemIndexKey].toString()) ?? -1;
    if (-1 == index) {
      ZegoLoggerService.logInfo(
        'ERROR!!! click seat index is invalid',
        tag: 'audio room',
        subTag: 'foreground',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'ERROR!!! click seat event is deal outside',
      tag: 'audio room',
      subTag: 'foreground',
    );

    widget.events.seat.onClicked!.call(index, widget.user);
    return;
  }

  Widget hostFlag(BuildContext context, double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(maxWidth, seatHostFlagHeight)),
      child: Center(
        child: ZegoLiveAudioRoomImage.asset(ZegoLiveAudioRoomIconUrls.seatHost,
            color: Colors.amberAccent,
            scale: .3),
      ),
    );
  }

  Widget coHostFlag(BuildContext context, double maxWidth) {
    return Center(
      child: ZegoLiveAudioRoomImage.asset(
        ZegoLiveAudioRoomIconUrls.seatCoHost,
          color: Colors.amberAccent,
          scale: .3
      ),
    );
  }

  Widget userName(BuildContext context, double maxWidth) {
    return SizedBox(
      width: maxWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.seatManager.isAttributeHost(widget.user))
              Expanded(child: hostFlag(context, maxWidth)),
    if (widget.seatManager.isCoHost(widget.user))
              Expanded(child: coHostFlag(context, maxWidth)),

            Expanded(flex: 5,
              child: Text(
                widget.user?.name ?? '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: seatUserNameFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userAttractive(attractiveCount, double maxWidth) {
    return SizedBox(
      width: maxWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 14,
              color:attractiveCount==null?Colors.transparent: Colors.red,
            ),
            Text(
              attractiveCount ?? '',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: seatUserNameFontSize - 2,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget microphoneOffFlag() {
    return widget.user?.microphone.value ?? false
        ? Positioned(
            // top: avatarPosTop,
            left: 0,
            right: -110.zR,
            bottom: 50.zR,
            child: Container(
              width: seatIconWidth / 2.5,
              height: seatIconWidth / 2.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB18A66).withOpacity(0.9),
              ),
              child: ZegoLiveAudioRoomImage.asset(
                ZegoLiveAudioRoomIconUrls.seatMicrophoneOn,
              ),
            ),
          )
        : Positioned(
            // top: avatarPosTop,
            left: 0,
            right: -90.zR,
            bottom: 40.zR,
            child: Container(
              width: seatIconWidth / 2.5,
              height: seatIconWidth / 2.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB18A66).withOpacity(0.9),
              ),
              child: ZegoLiveAudioRoomImage.asset(
                ZegoLiveAudioRoomIconUrls.seatMicrophoneOff,
              ),
            ),
          );
  }
}
