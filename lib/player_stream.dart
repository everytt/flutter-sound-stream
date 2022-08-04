library player;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart' show Level, Logger;
import 'package:sound_stream/platform_interface/player_platform_interface.dart';
import 'package:sound_stream/stream.dart';
import 'package:synchronized/synchronized.dart';

const _blockSize = 4096;

/// The possible states of the Player.
enum PlayerState {
  /// Player is stopped
  isStopped,

  /// Player is playing
  isPlaying,

  /// Player is paused
  isPaused,
}

class PlayerStream implements PlayerCallback {
  Logger _logger = Logger(level: Level.debug);
  Level _logLevel = Level.debug;

  Logger get logger => _logger;

  Initialized _isInited = Initialized.notInitialized;

  PlayerState _playerState = PlayerState.isStopped;
  PlayerState get playerStatus => _playerState;

  final _lock = Lock();

  StreamSubscription<Food>? _foodStreamSubscription;
  StreamController<Food>? _foodStreamController;

  Completer<int>? _needSomeFoodCompleter;

  Completer<void>? _startPlayerCompleter;
  Completer<void>? _pausePlayerCompleter;
  Completer<void>? _resumePlayerCompleter;
  Completer<void>? _stopPlayerCompleter;
  Completer<void>? _closePlayerCompleter;
  Completer<PlayerStream>? _openPlayerCompleter;

  /// Test the Player State
  bool get isPlaying => _playerState == PlayerState.isPlaying;

  /// Test the Player State
  bool get isPaused => _playerState == PlayerState.isPaused;

  /// Test the Player State
  bool get isStopped => _playerState == PlayerState.isStopped;


  PlayerStream({Level logLevel = Level.debug}) {
    print("PlayerStream :::::: init");

    _logger = Logger(level: logLevel);
    _logger.d('ctor: PlayerStream()');
  }

  @override
  void openPlayerCompleted(int state, bool success) {
    print("------> openPlayerCompleted: $success");

    _isInited = success ? Initialized.fullyInitialized : Initialized.notInitialized;
    _playerState = PlayerState.values[state];

    if (_openPlayerCompleter == null) {
      print("Error : cannot process _openPlayerCompleter");
      return;
    }

    if (success) {
      _openPlayerCompleter!.complete(this);
    } else {
      _openPlayerCompleter!.completeError("openPlayer failed");
    }

    _openPlayerCompleter = null;
    print("<----- openPlayerCompleted: $success");
  }
  @override
  void closePlayerCompleted(int state, bool success) {
    print("------> closePlayerCompleted: $success");

    // _playerStatus =
    _isInited = Initialized.notInitialized;

    if (_closePlayerCompleter == null) {
      print("Error : cannot process _closePlayerCompleter");
      return;
    }

    if (success) {
      _closePlayerCompleter!.complete(this);
    } else {
      _closePlayerCompleter!.completeError('closePlayer failed');
    }
    _closePlayerCompleter = null;
    _cleanCompleters();

    print("<------ closePlayerCompleted: $success");
  }

  @override
  void pausePlayerCompleted(int state, bool success) {
    print('---> pausePlayerCompleted: $success');
    if (_pausePlayerCompleter == null) {
      print('Error : cannot process _pausePlayerCompleter');
      return;
    }
    _playerState = PlayerState.values[state];
    if (success) {
      _pausePlayerCompleter!.complete();
    } else {
      _pausePlayerCompleter!.completeError('pausePlayer failed');
    }
    _pausePlayerCompleter = null;
    print('<--- pausePlayerCompleted: $success');
  }

  @override
  void resumePlayerCompleted(int state, bool success) {
    print('---> resumePlayerCompleted: $success');
    if (_resumePlayerCompleter == null) {
      print('Error : cannot process _resumePlayerCompleter');
      return;
    }
    _playerState = PlayerState.values[state];
    if (success) {
      _resumePlayerCompleter!.complete();
    } else {
      _resumePlayerCompleter!.completeError('resumePlayer failed');
    }
    _resumePlayerCompleter = null;
    print('<--- resumePlayerCompleted: $success');
  }


  @override
  void stopPlayerCompleted(int state, bool success) {
    print('---> stopPlayerCompleted: $success');
    if (_stopPlayerCompleter == null) {
      print('Error : cannot process stopPlayerCompleted');
      print('<--- stopPlayerCompleted: $success');
      return;
    }
    _playerState = PlayerState.values[state];
    if (success) {
      _stopPlayerCompleter!.complete();
    } // stopRecorder must not gives errors
    else {
      _stopPlayerCompleter!.completeError('stopPlayer failed');
    }
    _stopPlayerCompleter = null;
    print('<--- stopPlayerCompleted: $success');
  }

  Future<void> _waitOpen() async {
    while (_openPlayerCompleter != null) {
      print('Waiting for the player being opened');
      await _openPlayerCompleter!.future;
    }
    if (_isInited == Initialized.notInitialized) {
      throw Exception('Player is not open');
    }
  }

  Future<PlayerStream?> openPlayer(
      {bool enableVoiceProcessing = false}) async {
    //if (!Platform.isIOS && enableVoiceProcessing) {
    //throw ('VoiceProcessing is only available on iOS');
    //}

    if (_isInited != Initialized.notInitialized) {
      return this;
    }
    PlayerStream? r;
    await _lock.synchronized(() async {
      r = await _openAudioSession(enableVoiceProcessing: enableVoiceProcessing);
    });
    return r;
  }


  Future<PlayerStream> _openAudioSession(
      {bool enableVoiceProcessing = false}) async {
    _logger.d('FS:---> openAudioSession');
    while (_openPlayerCompleter != null) {
      _logger.w('Another openPlayer() in progress');
      await _openPlayerCompleter!.future;
    }

    Completer<PlayerStream>? completer;
    if (_isInited != Initialized.notInitialized) {
      throw Exception('Player is already initialized');
    }

    SoundPlayerPlatform.instance.openSession(this);
    assert(_openPlayerCompleter == null);
    _openPlayerCompleter = Completer<PlayerStream>();
    completer = _openPlayerCompleter;
    try {
      var state = await SoundPlayerPlatform.instance.openPlayer(this,
          logLevel: _logLevel, voiceProcessing: enableVoiceProcessing);
      _playerState = PlayerState.values[state];
      //isInited = success ?  Initialized.fullyInitialized : Initialized.notInitialized;
    } on Exception {
      _openPlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- openAudioSession');
    return completer!.future;
  }

  Future<void> closePlayer() async {
    await _lock.synchronized(() async {
      await _closeAudioSession();
    });
  }

  Future<void> _closeAudioSession() async {
    _logger.d('FS:---> closeAudioSession ');

    // If another closePlayer() is already in progress, wait until finished
    while (_closePlayerCompleter != null) {
      _logger.w('Another closePlayer() in progress');
      await _closePlayerCompleter!.future;
    }

    if (_isInited == Initialized.notInitialized) {
      // Already closed
      _logger.d('Player already close');
      return;
    }

    Completer<void>? completer;
    try {
      await _stop(); // Stop the player if running
      //_isInited = Initialized.initializationInProgress; // BOF

      assert(_closePlayerCompleter == null);
      _closePlayerCompleter = Completer<void>();
      completer = _closePlayerCompleter;
      await SoundPlayerPlatform.instance.closePlayer(this);
      SoundPlayerPlatform.instance.closeSession(this);
    } on Exception {
      _closePlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- closeAudioSession ');
    return completer!.future;
  }


  Future<void> startPlayerFromStream({
    int numChannels = 1,
    int sampleRate = 16000,
  }) async {
    await _lock.synchronized(() async {
      await _startPlayerFromStream(
        sampleRate: sampleRate,
        numChannels: numChannels,
      );
    });
  }


  /// Player will start receiving audio chunks (PCM 16bit data)
  /// to audiostream as Uint8List to play audio.
  Future<dynamic> _startPlayerFromStream({
    int numChannels = 1,
    int sampleRate = 16000,
  }) async {
    print('---> _startPlayerFromStream');
    await _waitOpen();
    if (_isInited != Initialized.fullyInitialized) {
      throw Exception('Player is not open');
    }

    Completer? completer;

    await _stop();

    _foodStreamController = StreamController();
    _foodStreamSubscription = _foodStreamController!.stream.listen((event) {
      _foodStreamSubscription!.pause(event.exec(this));
    });

    if (_startPlayerCompleter != null) {
      _logger.w('Killing another startPlayer()');
      _startPlayerCompleter!.completeError('Killed by another startPlayer()');
    }

    try {
      _startPlayerCompleter = Completer();
      completer = _startPlayerCompleter;

      var state = await SoundPlayerPlatform.instance.startPlayer(this,
          numChannels: numChannels,
          sampleRate: sampleRate);
      _playerState = PlayerState.values[state];
    } on Exception {
      _startPlayerCompleter = null;
      rethrow;
    }
    print('<--- _startPlayerFromStream');
    return completer!.future;
  }

  Future<PlayerState> getPlayerState() async {
    await _waitOpen();
    if (_isInited != Initialized.fullyInitialized) {
      throw Exception('Player is not open');
    }
    var state = await SoundPlayerPlatform.instance.getPlayerState(this);
    _playerState = PlayerState.values[state];
    return _playerState;
  }

  Future<void> _stop() async {
    _logger.d('FS:---> _stop ');
    if (_foodStreamSubscription != null) {
      await _foodStreamSubscription!.cancel();
      _foodStreamSubscription = null;
    }
    _needSomeFoodCompleter = null;
    if (_foodStreamController != null) {
      await _foodStreamController!.sink.close();
      await _foodStreamController!.close();
      _foodStreamController = null;
    }
    Completer<void>? completer;
    _stopPlayerCompleter = Completer<void>();
    try {
      completer = _stopPlayerCompleter;
      var state = await SoundPlayerPlatform.instance.stopPlayer(this);

      _playerState = PlayerState.values[state];
      if (_playerState != PlayerState.isStopped) {
        _logger.d('Player is not stopped!');
      }
    } on Exception {
      _stopPlayerCompleter = null;
      rethrow;
    }

    _logger.d('FS:<--- _stop ');
    return completer!.future;
  }

  Future<void> pausePlayer() async {
    _logger.d('FS:---> pausePlayer ');
    await _lock.synchronized(() async {
      await _pausePlayer();
    });
    _logger.d('FS:<--- pausePlayer ');
  }

  Future<void> _pausePlayer() async {
    _logger.d('FS:---> _pausePlayer ');
    await _waitOpen();
    if (_isInited != Initialized.fullyInitialized) {
      throw Exception('Player is not open');
    }
    Completer<void>? completer;
    if (_pausePlayerCompleter != null) {
      _logger.w('Killing another pausePlayer()');
      _pausePlayerCompleter!.completeError('Killed by another pausePlayer()');
    }
    try {
      _pausePlayerCompleter = Completer<void>();
      completer = _pausePlayerCompleter;
      _playerState = PlayerState
          .values[await SoundPlayerPlatform.instance.pausePlayer(this)];
      //if (_playerState != PlayerState.isPaused) {
      //throw _PlayerRunningException(
      //'Player is not paused.'); // I am not sure that it is good to throw an exception here
      //}
    } on Exception {
      _pausePlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- _pausePlayer ');
    return completer!.future;
  }

  Future<void> resumePlayer() async {
    _logger.d('FS:---> resumePlayer');
    await _lock.synchronized(() async {
      await _resumePlayer();
    });
    _logger.d('FS:<--- resumePlayer');
  }

  Future<void> _resumePlayer() async {
    _logger.d('FS:---> _resumePlayer');
    await _waitOpen();
    if (_isInited != Initialized.fullyInitialized) {
      throw Exception('Player is not open');
    }
    Completer<void>? completer;
    if (_resumePlayerCompleter != null) {
      _logger.w('Killing another resumePlayer()');
      _resumePlayerCompleter!.completeError('Killed by another resumePlayer()');
    }
    _resumePlayerCompleter = Completer<void>();
    try {
      completer = _resumePlayerCompleter;
      var state = await SoundPlayerPlatform.instance.resumePlayer(this);
      _playerState = PlayerState.values[state];
      //if (_playerState != PlayerState.isPlaying) {
      //throw _PlayerRunningException(
      //'Player is not resumed.'); // I am not sure that it is good to throw an exception here
      //}
    } on Exception {
      _resumePlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- _resumePlayer');
    return completer!.future;
  }

  Future<void> _stopPlayer() async {
    while (_openPlayerCompleter != null) {
      print("Waiting for player being opend");

      await _openPlayerCompleter!.future;
    }

    if (_isInited != Initialized.fullyInitialized) {
      print('<--- _stopPlayer : Player is not open');
      return;
    }

    try {
      //_removePlayerCallback(); // playerController is closed by this function
      await _stop();
    } on Exception catch (e) {
      _logger.e(e);
    }
  }

  Future<void> feedFromStream(Uint8List buffer) async {
    await _feedFromStream(buffer);
  }

  Future<void> _feedFromStream(Uint8List buffer) async {
    var lnData = 0;
    var totalLength = buffer.length;
    while (totalLength > 0 && !isStopped) {
      var bsize = totalLength > _blockSize ? _blockSize : totalLength;
      var ln = await _feed(buffer.sublist(lnData, lnData + bsize));
      assert(ln >= 0);
      lnData += ln;
      totalLength -= ln;
    }
  }

  Future<int> _feed(Uint8List data) async {
    await _waitOpen();
    if (_isInited != Initialized.fullyInitialized) {
      throw Exception('Player is not open');
    }
    if (isStopped) {
      return 0;
    }
    _needSomeFoodCompleter = Completer<int>();
    try {
      var ln = await (SoundPlayerPlatform.instance.feed(
        this,
        data: data,
      ));

      assert(ln >= 0); // feedFromStream() is not happy if < 0
      if (ln != 0) {
        _needSomeFoodCompleter = null;
        return (ln);
      }
    } on Exception {
      _needSomeFoodCompleter = null;
      if (isStopped) {
        return 0;
      }
      rethrow;
    }

    if (_needSomeFoodCompleter != null) {
      return _needSomeFoodCompleter!.future;
    }
    return 0;
  }

    /// Stream's sink to receive PCM 16bit data to send to Player
  StreamSink<Food>? get foodSink => _foodStreamController != null ? _foodStreamController!.sink : null;

  Future<void> stopPlayer() async {
    await _lock.synchronized(() async {
      await _stopPlayer();
    });
  }

  void log(Level logLevel, String msg) {
    _logger.log(logLevel, msg);
  }

  void needSomeData(int ln) {
    assert(ln >= 0);
    _needSomeFoodCompleter?.complete(ln);
  }

  /// Stop and close all streams. This cannot be undone
  /// Only call this method if you don't want to use this anymore
  void dispose() async {
    await _stop();
    _foodStreamSubscription?.cancel();
    _foodStreamController?.close();
  }

  void _cleanCompleters() {
    if (_pausePlayerCompleter != null) {
      var completer = _pausePlayerCompleter;
      _logger.w('Kill _pausePlayer()');
      _pausePlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_resumePlayerCompleter != null) {
      var completer = _resumePlayerCompleter;
      _logger.w('Kill _resumePlayer()');
      _resumePlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_startPlayerCompleter != null) {
      var completer = _startPlayerCompleter;
      _logger.w('Kill _startPlayer()');
      _startPlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_stopPlayerCompleter != null) {
      var completer = _stopPlayerCompleter;
      _logger.w('Kill _stopPlayer()');
      _stopPlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_openPlayerCompleter != null) {
      var completer = _openPlayerCompleter;
      _logger.w('Kill openPlayer()');
      _openPlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_closePlayerCompleter != null) {
      var completer = _closePlayerCompleter;
      _logger.w('Kill _closePlayer()');
      _closePlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }
  }

  @override
  void needSomeFood(int ln) {
    assert(ln >= 0);
    _needSomeFoodCompleter?.complete(ln);
  }

  @override
  void startPlayerCompleted(int state, bool success) {
    print("-------> startPlayerCompleted: $success");

    if (_startPlayerCompleter == null) {
      print("Error : cannot process _startPlayerCompleter");
      return;
    }
    //  _playerState = PlayerState.values[state];

    if (success) {
      _startPlayerCompleter!.complete();
    } else {
      _startPlayerCompleter!.completeError('startPlayer() failed');
    }
    _startPlayerCompleter = null;
    print('<--- startPlayerCompleted: $success');
  }
}
