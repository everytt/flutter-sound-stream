import 'package:flutter/services.dart';
import 'package:logger/logger.dart' show Level, Logger;
import 'package:sound_stream/platform_interface/player_platform_interface.dart';
import 'dart:typed_data' show Uint8List;

/// An implementation of [FlutterSoundPlayerPlatform] that uses method channels.
class MethodChannelPlayer extends SoundPlayerPlatform {
  static const MethodChannel _channel = MethodChannel("vn.casperpas.sound_stream:player");

  /* ctor */ MethodChannelPlayer() {
    print("FLUTTER ::::: MethodChannelPlayer -> init");
    setCallback();
  }

  void setCallback() {
    _channel.setMethodCallHandler((MethodCall call) {
      return channelMethodCallHandler(call)!;
    });
  }

  Future<dynamic>? channelMethodCallHandler(MethodCall call) {
    PlayerCallback aPlayer = getSession(call.arguments!['slotNo'] as int);
    Map arg = call.arguments;
    // print("[PLAYER/KT] FLUTTER  channelMethodCallHandler : ${call.method}" );

    bool success = call.arguments['success'] != null ? call.arguments['success'] as bool : false;

    switch (call.method) {
      case "needSomeFood":
        {
          aPlayer.needSomeFood(arg['arg']);
        }
        break;
      case 'openPlayerCompleted':
        {
          aPlayer.openPlayerCompleted(call.arguments['state'], success);
        }
        break;
      case 'startPlayerCompleted':
        {
          //int duration = arg['duration'] as int;
          aPlayer.startPlayerCompleted(call.arguments['state'], success);
        }
        break;
      case "stopPlayerCompleted":
        {
          aPlayer.stopPlayerCompleted(call.arguments['state'], success);
        }
        break;

      case "pausePlayerCompleted":
        {
          aPlayer.pausePlayerCompleted(call.arguments['state'], success);
        }
        break;

      case "resumePlayerCompleted":
        {
          aPlayer.resumePlayerCompleted(call.arguments['state'], success);
        }
        break;

      case "closePlayerCompleted":
        {
          aPlayer.closePlayerCompleted(call.arguments['state'], success);
        }
        break;

      case "log":
        {
          aPlayer.log(Level.values[call.arguments['level']], call.arguments['msg']);
        }
        break;

      default:
        throw ArgumentError('Unknown method ${call.method}');
    }
    return null;
  }

//===============================================================================================================================

  Future<int> invokeMethod(PlayerCallback callback, String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as int;
  }

  Future<String> invokeMethodString(PlayerCallback callback, String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as String;
  }

  Future<bool> invokeMethodBool(PlayerCallback callback, String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as bool;
  }

  Future<Map> invokeMethodMap(PlayerCallback callback, String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    var r = await _channel.invokeMethod(methodName, call);
    return r;
  }

  @override
  Future<void>? setLogLevel(PlayerCallback callback, Level logLevel) {
    invokeMethod(callback, 'setLogLevel', {
      'logLevel': logLevel.index,
    });
  }

  @override
  Future<void>? resetPlugin(
    PlayerCallback callback,
  ) {
    return _channel.invokeMethod(
      'resetPlugin',
    );
  }

  @override
  Future<int> openPlayer(PlayerCallback callback, {required Level logLevel, bool voiceProcessing = false}) {
    return invokeMethod(
      callback,
      'openPlayer',
      {'logLevel': logLevel.index, 'voiceProcessing': voiceProcessing},
    );
  }

  @override
  Future<int> closePlayer(
    PlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'closePlayer',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<int> getPlayerState(
    PlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'getPlayerState',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<Map<String, Duration>> getProgress(
    PlayerCallback callback,
  ) async {
    var m2 = await invokeMethodMap(
      callback,
      'getProgress',
      Map<String, dynamic>(),
    );
    Map<String, Duration> r = {
      'duration': Duration(milliseconds: m2['duration']!),
      'progress': Duration(milliseconds: m2['position']!),
    };
    return r;
  }

  @override
  Future<int> startPlayer(PlayerCallback callback, {int? numChannels, int? sampleRate}) {
    return invokeMethod(
      callback,
      'startPlayer',
      {'numChannels': numChannels, 'sampleRate': sampleRate},
    );
  }

  @override
  Future<int> feed(
    PlayerCallback callback, {
    Uint8List? data,
  }) {
    return invokeMethod(
      callback,
      'feed',
      {
        'data': data,
      },
    );
  }

  @override
  Future<int> stopPlayer(
    PlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'stopPlayer',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<int> pausePlayer(
    PlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'pausePlayer',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<int> resumePlayer(
    PlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'resumePlayer',
      Map<String, dynamic>(),
    );
  }
}
