import 'dart:typed_data' show Uint8List;

import 'package:logger/logger.dart' show Level, Logger;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sound_stream/platform_interface/method_channel_recorder.dart';


enum RecorderState {
  isStopped,
  isPaused,
  isRecording,
}


enum AudioSource {
  defaultSource,
  microphone,
  voiceDownlink, // (it does not work, at least on Android. Probably problems with the authorization )
  camCorder,
  remote_submix,
  unprocessed,
  voice_call,
  voice_communication,
  voice_performance,
  voice_recognition,
  voiceUpLink,// (it does not work, at least on Android. Probably problems with the authorization )
  bluetoothHFP,
  headsetMic,
  lineIn,
}


abstract class RecorderCallback
{
  void recordingData({Uint8List? data} );
  void startRecorderCompleted(int? state, bool? success);
  void pauseRecorderCompleted(int? state, bool? success);
  void resumeRecorderCompleted(int? state, bool? success);
  void stopRecorderCompleted(int? state, bool? success);
  void openRecorderCompleted(int? state, bool? success);
  void closeRecorderCompleted(int? state, bool? success);
  void log(Level logLevel, String msg);

}


abstract class SoundRecorderPlatform extends PlatformInterface {

  /// Constructs a UrlLauncherPlatform.
  SoundRecorderPlatform() : super(token: _token);

  static final Object _token = Object();

  static SoundRecorderPlatform _instance = MethodChannelRecorder();

  /// The default instance of [SoundRecorderPlatform] to use.
  ///
  /// Defaults to [MethodChannelRecorder].
  static SoundRecorderPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UrlLauncherPlatform] when they register themselves.
  static set instance(SoundRecorderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }



  List<RecorderCallback?> _slots = [];


  int findSession(RecorderCallback aSession)
  {
    for (var i = 0; i < _slots.length; ++i)
    {
      if (_slots[i] == aSession)
      {
        return i;
      }
    }
    return -1;
  }

  void openSession(RecorderCallback aSession)
  {
    assert(findSession(aSession) == -1);

    for (var i = 0; i < _slots.length; ++i)
    {
      if (_slots[i] == null)
      {
        _slots[i] = aSession;
        return;
      }
    }
    _slots.add(aSession);
  }

  void closeSession(RecorderCallback aSession)
  {
    _slots[findSession(aSession)] = null;
  }

  RecorderCallback? getSession(int slotno)
  {
    return _slots[slotno];
  }



  Future<void>? setLogLevel(RecorderCallback callback, Level loglevel)
  {
    throw UnimplementedError('setLogLeve() has not been implemented.');
  }


  Future<void>?   resetPlugin(RecorderCallback callback,)
  {
    throw UnimplementedError('resetPlugin() has not been implemented.');
  }


  Future<void> openRecorder(RecorderCallback callback, {required Level logLevel, })
  {
    throw UnimplementedError('openRecorder() has not been implemented.');
  }

  Future<void> closeRecorder(RecorderCallback callback, )
  {
    throw UnimplementedError('closeRecorder() has not been implemented.');
  }

  Future<void> startRecorder(RecorderCallback callback,
      {
        int? sampleRate,
        int? numChannels,
        int? bitRate,
        AudioSource? audioSource,
      })
  {
    throw UnimplementedError('startRecorder() has not been implemented.');
  }

  Future<void> stopRecorder(RecorderCallback callback, )
  {
    throw UnimplementedError('stopRecorder() has not been implemented.');
  }

  Future<void> pauseRecorder(RecorderCallback callback, )
  {
    throw UnimplementedError('pauseRecorder() has not been implemented.');
  }

  Future<void> resumeRecorder(RecorderCallback callback, )
  {
    throw UnimplementedError('resumeRecorder() has not been implemented.');
  }
  }