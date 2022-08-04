/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */


import 'dart:async';

import 'package:logger/logger.dart' show Level , Logger;
import 'package:flutter/services.dart';
import 'package:sound_stream/platform_interface/recorder_platform_interface.dart';


/// An implementation of [UrlLauncherPlatform] that uses method channels.
class MethodChannelRecorder extends SoundRecorderPlatform
{
  static const MethodChannel _channel = MethodChannel('vn.casperpas.sound_stream:methods_recorder');

  /*ctor */ MethodChannelRecorder()
{
  _setCallback();
}

void _setCallback()
{
  _channel.setMethodCallHandler((MethodCall call)
  {
    return channelMethodCallHandler(call)!;
  });
}



Future<dynamic>? channelMethodCallHandler(MethodCall call) {
  RecorderCallback? aRecorder = getSession(call.arguments['slotNo'] as int);
  //bool? success = call.arguments['success'] as bool?;
  bool success = call.arguments['success'] != null ? call.arguments['success'] as bool : false;

  print("[RECODER/DART] FLUTTER channelMethodCallHandler : ${call.method} / recorder :: $aRecorder" );
  switch (call.method) {
    case "recordingData":
      {
        aRecorder!.recordingData(data: call.arguments['recordingData'] );
      }
      break;

    case "startRecorderCompleted":
      {
        aRecorder!.startRecorderCompleted(call.arguments['state'], success );
      }
      break;

    case "stopRecorderCompleted":
      {
        aRecorder!.stopRecorderCompleted(call.arguments['state'] , success);
      }
      break;

    case "pauseRecorderCompleted":
      {
        aRecorder!.pauseRecorderCompleted(call.arguments['state'] , success);
      }
      break;

    case "resumeRecorderCompleted":
      {
        aRecorder!.resumeRecorderCompleted(call.arguments['state'] , success);
      }
      break;

    case "openRecorderCompleted":
      {
        aRecorder!.openRecorderCompleted(call.arguments['state'], success );
      }
      break;

    case "closeRecorderCompleted":
      {
        aRecorder!.closeRecorderCompleted(call.arguments['state'], success );
      }
      break;

    case "log":
      {
        aRecorder!.log(Level.values[call.arguments['logLevel']], call.arguments['msg']);
      }
      break;


    default:
      throw ArgumentError('Unknown method ${call.method}');
  }

  return null;
}



Future<void> invokeMethodVoid (RecorderCallback callback,  String methodName, Map<String, dynamic> call)
{
  call['slotNo'] = findSession(callback);
  return _channel.invokeMethod(methodName, call);
}


Future<int?> invokeMethodInt (RecorderCallback callback,  String methodName, Map<String, dynamic> call)
{
  call['slotNo'] = findSession(callback);
  return _channel.invokeMethod(methodName, call);
}


Future<bool> invokeMethodBool (RecorderCallback callback,  String methodName, Map<String, dynamic> call) async
{
  call['slotNo'] = findSession(callback);
  bool r = await _channel.invokeMethod(methodName, call) as bool;
  return r;
}

Future<String?> invokeMethodString (RecorderCallback callback, String methodName, Map<String, dynamic> call)
{
  call['slotNo'] = findSession(callback);
  return _channel.invokeMethod(methodName, call);
}


@override
Future<void>? setLogLevel(RecorderCallback callback, Level logLevel)
{
  return invokeMethodVoid( callback, 'setLogLevel', {'logLevel': logLevel.index,});
}

@override
Future<void>? resetPlugin(RecorderCallback callback,)
{
  return invokeMethodVoid( callback, 'resetPlugin', Map<String, dynamic>(),);
}

@override
Future<void> openRecorder( RecorderCallback callback, {required Level logLevel,  })
{
  return invokeMethodVoid( callback, 'openRecorder', {'logLevel': logLevel.index,  },) ;
}

@override
Future<void> closeRecorder(RecorderCallback callback, )
{
  return invokeMethodVoid( callback, 'closeRecorder',  Map<String, dynamic>(),);
}

@override
Future<void> startRecorder(RecorderCallback callback,
    {
      int? sampleRate,
      int? numChannels,
      int? bitRate,
      AudioSource? audioSource,
    })
{
  return invokeMethodVoid( callback, 'startRecorder',
    {
      'sampleRate': sampleRate,
      'numChannels': numChannels,
      'bitRate': bitRate,
      'audioSource': audioSource!.index,
    },);
}

@override
Future<void> stopRecorder(RecorderCallback callback,  )
{
  return invokeMethodVoid( callback, 'stopRecorder',  Map<String, dynamic>(),) ;
}

@override
Future<void> pauseRecorder(RecorderCallback callback,  )
{
  return invokeMethodVoid( callback, 'pauseRecorder',  Map<String, dynamic>(),) ;
}

@override
Future<void> resumeRecorder(RecorderCallback callback, )
{
  return invokeMethodVoid( callback, 'resumeRecorder', Map<String, dynamic>(),) ;
}

}