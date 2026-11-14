import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String roomId;
  final String userId;
  final String userName;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    // Get App ID and App Sign from ZEGOCLOUD Console
    const int appID = 123456789; 
    const String appSign = "your_zego_app_sign_here";

    return ZegoUIKitPrebuiltCall(
      appID: appID,
      appSign: appSign,
      userID: userId,
      userName: userName,
      callID: roomId,
      config: isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}