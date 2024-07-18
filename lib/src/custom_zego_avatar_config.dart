import '../zego_uikit_prebuilt_live_audio_room.dart';

class CustomZegoUser extends ZegoUIKitUser{
  Stream? attractiveCount;

  CustomZegoUser({
    this.attractiveCount,
    id,
    name,

  }) : super( id: id,name: name);


}