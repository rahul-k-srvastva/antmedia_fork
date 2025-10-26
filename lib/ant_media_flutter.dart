// ignore_for_file: prefer_generic_function_type_aliases, constant_identifier_names

import 'dart:async';

import 'package:ant_media_flutter/src/helpers/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

// HelperState is used to determine the state of the websocket connection between the device and the Ant Media Server
enum HelperState {
  CallStateNew,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

// AntMedia Media Types is used to determine different modes of Ant Media Server
enum AntMediaType { Default, Publish, Play, Peer, Conference, DataChannelOnly }

typedef void HelperStateCallback(HelperState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data, bool isReceived);
typedef void DataChannelCallback(RTCDataChannel dc);
typedef void ConferenceUpdateCallback(dynamic streams);
typedef void Callbacks(String command, Map mapData);

class DataChannelMessage extends Object {
  RTCDataChannelMessage message;
  bool isRecieved;
  RTCDataChannel channel;
  DataChannelMessage(this.isRecieved, this.channel, this.message);
}

class AntMediaFlutter {
  static AntHelper? anthelper;

  // requestPermissions is used to request permissions for camera, microphone and bluetoothConnect
  static void requestPermissions() {
    Permission.camera
        .request()
        .then((value) => Permission.microphone.request().then((value) => {
              if (value.isGranted && !kIsWeb)
                {Permission.bluetoothConnect.request().then((value) => null)}
            }));
  }

  // startForegroundService is used to start the background service for the app
  // it should be called on the Android platform
  static Future<bool> startForegroundService() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Title of the notification',
      notificationText: 'Text of the notification',
      notificationImportance: AndroidNotificationImportance.normal,
      notificationIcon:
          AndroidResource(name: 'background_icon', defType: 'drawable'),
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    return FlutterBackground.enableBackgroundExecution();
  }

  // connect is the entry point for the plugin
  // it is used to connect to the Ant Media Server
  static void connect({
    required String ip,
    required String streamId,
    required String streamName,
    required String roomId,
    required InitialCamera initialCamera,
    required String token,
    required AntMediaType type,
    required bool userScreen,
    required HelperStateCallback onStateChange,
    required StreamStateCallback onLocalStream,
    required StreamStateCallback onAddRemoteStream,
    required DataChannelCallback onDataChannel,
    required DataChannelMessageCallback onDataChannelMessage,
    required ConferenceUpdateCallback onupdateConferencePerson,
    required StreamStateCallback onRemoveRemoteStream,
    required List<Map<String, String>> iceServers,
    required Callbacks callbacks,
  }) async {
    anthelper = null;
    anthelper ??= AntHelper(
      //host
      host: ip,

      //streamID
      streamId: streamId,

      //Stream name
      streamName: streamName,

      initialCamera: initialCamera,

      //roomID
      roomId: roomId,

      //token
      token: token,

      //onStateChange
      onStateChange: onStateChange,

      //onAddRemoteStream
      onAddRemoteStream: onAddRemoteStream,

      //onDataChannel
      onDataChannel: onDataChannel,

      //onDataChannelMessage
      onDataChannelMessage: onDataChannelMessage,

      //onLocalStream
      onLocalStream: onLocalStream,

      //onRemoveRemoteStream
      onRemoveRemoteStream: onRemoveRemoteStream,

      //ScreenSharing
      userScreen: userScreen,

      // onupdateConferencePerson
      onupdateConferencePerson: onupdateConferencePerson,

      //iceServers
      iceServers: iceServers,

      //callbacks
      callbacks: callbacks,
    )..connect(type);
  }
}

enum InitialCamera { front, rear }
