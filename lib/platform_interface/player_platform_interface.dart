
import 'package:logger/logger.dart' show Level, Logger;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sound_stream/platform_interface/method_channel_player.dart';
import 'dart:typed_data' show Uint8List;


abstract class PlayerCallback
{
  void needSomeFood(int ln);
  void startPlayerCompleted(int state, bool success);
  void pausePlayerCompleted(int state, bool success);
  void resumePlayerCompleted(int state, bool success);
  void stopPlayerCompleted(int state, bool success);
  void openPlayerCompleted(int state, bool success);
  void closePlayerCompleted(int state, bool success);
  void log(Level logLevel, String msg);
}



abstract class SoundPlayerPlatform extends PlatformInterface {

  /// Constructs a UrlLauncherPlatform.
  SoundPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SoundPlayerPlatform _instance = MethodChannelPlayer();

  /// The default instance of [FlutterSoundPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSoundPlayer].
  static SoundPlayerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MethodChannelFlutterSoundPlayer] when they register themselves.
  static set instance(SoundPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }


  List<PlayerCallback?> _slots = [];

  int findSession(PlayerCallback aSession)
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

  void openSession(PlayerCallback aSession,)
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

  void closeSession(PlayerCallback aSession)
  {
    _slots[findSession(aSession)] = null;
  }

  PlayerCallback getSession(int slotno)
  {
    PlayerCallback? cb = _slots[slotno];
    if (cb == null)
      throw Exception('Cannot find session');
    else
      return cb;
  }

  //===================================================================================================================================================

  Future<void>?   setLogLevel(PlayerCallback callback, Level loglevel)
  {
    throw UnimplementedError('setLogLeve() has not been implemented.');
  }

  Future<void>?   resetPlugin(PlayerCallback callback)
  {
    throw UnimplementedError('resetPlugin() has not been implemented.');
  }

  Future<int> openPlayer(PlayerCallback callback, {required Level logLevel, bool voiceProcessing=false})
  {
    throw UnimplementedError('openPlayer() has not been implemented.');
  }

  Future<int> closePlayer(PlayerCallback callback, )
  {
    throw UnimplementedError('closePlayer() has not been implemented.');
  }

  Future<int> getPlayerState(PlayerCallback callback, )
  {
    throw UnimplementedError('getPlayerState() has not been implemented.');
  }

  Future<int> startPlayer(PlayerCallback callback, {int? numChannels, int? sampleRate})
  {
    throw UnimplementedError('startPlayer() has not been implemented.');
  }

  Future<int> feed(PlayerCallback callback, {Uint8List? data, })
  {
    throw UnimplementedError('feed() has not been implemented.');
  }

  Future<int> stopPlayer(PlayerCallback callback,  )
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> pausePlayer(PlayerCallback callback,  )
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> resumePlayer(PlayerCallback callback,  )
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }
  }
