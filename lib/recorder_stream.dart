library recorder;

import 'dart:async';
import 'dart:typed_data';

import 'package:logger/logger.dart' show Level, Logger;
import 'package:sound_stream/platform_interface/recorder_platform_interface.dart';
import 'package:sound_stream/stream.dart';
import 'package:synchronized/synchronized.dart';
import 'sound_stream.dart';

class RecorderStream extends RecorderCallback {
  Logger _logger = Logger(level: Level.debug);
  Level _logLevel = Level.debug;

  Logger get logger => _logger;

  Future<void> setLogLevel(Level aLevel) async {
    _logLevel = aLevel;
    _logger = Logger(level: aLevel);
    await _lock.synchronized(() async {
      if (_isInited != Initialized.notInitialized) {
        await SoundRecorderPlatform.instance.setLogLevel(
          this,
          aLevel,
        );
      }
    });
  }

  Completer<void>? _startRecorderCompleter;
  Completer<void>? _pauseRecorderCompleter;
  Completer<void>? _resumeRecorderCompleter;
  Completer<void>? _stopRecorderCompleter;
  Completer<void>? _closeRecorderCompleter;
  Completer<RecorderStream>? _openRecorderCompleter;

  Initialized _isInited = Initialized.notInitialized;

  RecorderState _recorderState = RecorderState.isStopped;

  /// True if `recorderState.isRecording`
  bool get isRecording => (_recorderState == RecorderState.isRecording);

  /// True if `recorderState.isStopped`
  bool get isStopped => (_recorderState == RecorderState.isStopped);

  // /// True if `recorderState.isPaused`
  bool get isPaused => (_recorderState == RecorderState.isPaused);

  final _lock = Lock();

  StreamSink<Food>? _userStreamSink;

  RecorderStream({Level logLevel = Level.debug}) {
    _logger = Logger(level: logLevel);
    _logger.d('ctor: RecorderStream()');
  }

  /// Stop and close all streams. This cannot be undone
  /// Only call this method if you don't want to use this anymore
  void dispose() {
    _stop();
  }

  Future<void> _waitOpen() async {
    while (_openRecorderCompleter != null) {
      _logger.w('Waiting for the recorder being opened');
      await _openRecorderCompleter!.future;
    }
    if (_isInited == Initialized.notInitialized) {
      throw Exception('Recorder is not open');
    }
  }

  Future<RecorderStream?> openRecorder() async {
    if (_isInited != Initialized.notInitialized) {
      return this;
    }

    RecorderStream? r;
    _logger.d('FS:---> openAudioSession ');
    await _lock.synchronized(() async {
      r = await _openAudioSession();
    });
    _logger.d('FS:<--- openAudioSession ');
    return r;
  }

  Future<RecorderStream> _openAudioSession() async {
    _logger.d('---> openAudioSession');

    Completer<RecorderStream>? completer;

    if (_userStreamSink != null) {
      await _userStreamSink!.close();
      _userStreamSink = null;
    }
    assert(_openRecorderCompleter == null);
    _openRecorderCompleter = Completer<RecorderStream>();
    completer = _openRecorderCompleter;
    try {
      SoundRecorderPlatform.instance.openSession(this);
      await SoundRecorderPlatform.instance.openRecorder(
        this,
        logLevel: _logLevel,
      );

      //_isInited = Initialized.fullyInitialized;
    } on Exception {
      _openRecorderCompleter = null;
      rethrow;
    }
    _logger.d('<--- openAudioSession');
    return completer!.future;
  }

  Future<void> startRecorder({
    StreamSink<Food>? toStream,
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
    AudioSource audioSource = AudioSource.defaultSource,
  }) async {
    _logger.d('FS:---> startRecorder ');
    await _lock.synchronized(() async {
      await _startRecorder(
        toStream: toStream,
        sampleRate: sampleRate,
        numChannels: numChannels,
        bitRate: bitRate,
        audioSource: audioSource,
      );
    });
    _logger.d('FS:<--- startRecorder ');
  }

  Future<void> _startRecorder({
    String? toFile,
    StreamSink<Food>? toStream,
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
    AudioSource audioSource = AudioSource.defaultSource,
  }) async {
    _logger.d('FS:---> _startRecorder.');
    await _waitOpen();
    if (_isInited != Initialized.fullyInitialized) {
      throw Exception('Recorder is not open');
    }

    if (_recorderState != RecorderState.isStopped) {
      throw _RecorderRunningException('Recorder is not stopped.');
    }

    if ((toFile == null && toStream == null) || (toFile != null && toStream != null)) {
      throw Exception('One, and only one parameter "toFile"/"toStream" must be provided');
    }

    Completer<void>? completer;
    // Maybe we should stop any recording already running... (stopRecorder does that)
    _userStreamSink = toStream;
    if (_startRecorderCompleter != null) {
      _startRecorderCompleter!.completeError('Killed by another startRecorder()');
    }
    _startRecorderCompleter = Completer<void>();
    completer = _startRecorderCompleter;
    try {
      await SoundRecorderPlatform.instance
          .startRecorder(this, sampleRate: sampleRate, numChannels: numChannels, bitRate: bitRate, audioSource: audioSource);

      _recorderState = RecorderState.isRecording;
    } on Exception {
      _startRecorderCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- _startRecorder.');
    return completer!.future;
  }

  Future<void> _stop() async {
    _logger.d('FS:---> _stop');
    _stopRecorderCompleter = Completer<void>();
    var completer = _stopRecorderCompleter!;
    try {
      await SoundRecorderPlatform.instance.stopRecorder(this);
      _userStreamSink = null;

      _recorderState = RecorderState.isStopped;
    } on Exception {
      _stopRecorderCompleter = null;
      rethrow;
    }

    _logger.d('FS:<--- _stop');
    return completer.future;
  }

  Future<String?> stopRecorder() async {
    _logger.d('FS:---> stopRecorder ');
    String? r;
    await _lock.synchronized(() async {
      await _stopRecorder();
    });
    _logger.d('FS:<--- stopRecorder ');
    return r;
  }

  Future<void> _stopRecorder() async {
    _logger.d('FS:---> _stopRecorder ');
    while (_openRecorderCompleter != null) {
      _logger.w('Waiting for the recorder being opened');
      await _openRecorderCompleter!.future;
    }
    if (_isInited != Initialized.fullyInitialized) {
      _logger.d('<--- _stopRecorder : Recorder is not open');
      return ; //'Recorder is not open';
    }
    String? r;

    try {
      await _stop();
    } on Exception catch (e) {
      _logger.e(e);
    }
    _logger.d('FS:<--- _stopRecorder : $r');
    return;
  }


  Future<void> closeRecorder() async {
    _logger.d('FS:---> closeAudioSession ');
    await _lock.synchronized(() async {
      await _closeAudioSession();
    });
    _logger.d('FS:<--- closeAudioSession ');
  }

  Future<void> _closeAudioSession() async {
    _logger.d('FS:---> closeAudioSession ');
    // If another closeRecorder() is already in progress, wait until finished
    while (_closeRecorderCompleter != null) {
      try {
        _logger.w('Another closeRecorder() in progress');
        await _closeRecorderCompleter!.future;
      } catch (_) {}
    }
    if (_isInited == Initialized.notInitialized) {
      // Already close
      _logger.i('Recorder already close');
      return;
    }

    Completer<void>? completer;

    try {
      await _stop(); // Stop the recorder if running
    } catch (e) {
      _logger.e(e.toString());
    }
    //_isInited = Initialized.initializationInProgress; // BOF
    if (_userStreamSink != null) {
      await _userStreamSink!.close();
      _userStreamSink = null;
    }
    assert(_closeRecorderCompleter == null);
    _closeRecorderCompleter = Completer<void>();
    try {
      completer = _closeRecorderCompleter;

      await SoundRecorderPlatform.instance.closeRecorder(this);
      SoundRecorderPlatform.instance.closeSession(this);
      //_isInited = Initialized.notInitialized;
    } on Exception {
      _closeRecorderCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- closeAudioSession ');
    return completer!.future;
  }

  void _cleanCompleters() {
    if (_pauseRecorderCompleter != null) {
      _logger.w('Kill _pauseRecorder()');
      var completer = _pauseRecorderCompleter!;
      _pauseRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }
    if (_resumeRecorderCompleter != null) {
      _logger.w('Kill _resumeRecorder()');
      var completer = _resumeRecorderCompleter!;
      _resumeRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_startRecorderCompleter != null) {
      _logger.w('Kill _startRecorder()');
      var completer = _startRecorderCompleter!;
      _startRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_stopRecorderCompleter != null) {
      _logger.w('Kill _stopRecorder()');
      Completer<void> completer = _stopRecorderCompleter!;
      _stopRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_openRecorderCompleter != null) {
      _logger.w('Kill openRecorder()');
      Completer<void> completer = _openRecorderCompleter!;
      _openRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_closeRecorderCompleter != null) {
      _logger.w('Kill _closeRecorder()');
      var completer = _closeRecorderCompleter!;
      _closeRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }
  }

  @override
  void closeRecorderCompleted(int? state, bool? success) {
    _logger.d('---> closeRecorderCompleted');
    _recorderState = RecorderState.values[state!];
    _isInited = Initialized.notInitialized;
    _closeRecorderCompleter!.complete();
    _closeRecorderCompleter = null;
    _cleanCompleters();
    _logger.d('<--- closeRecorderCompleted');
  }

  @override
  void log(Level logLevel, String msg) {
    _logger.log(logLevel, msg);
  }

  @override
  void openRecorderCompleted(int? state, bool? success) {
    _logger.d('---> openRecorderCompleted: $success');

    _recorderState = RecorderState.values[state!];
    _isInited = success! ? Initialized.fullyInitialized : Initialized.notInitialized;
    if (success) {
      _openRecorderCompleter!.complete(this);
    } else {
      _pauseRecorderCompleter!.completeError('openRecorder failed');
    }
    _openRecorderCompleter = null;
    _logger.d('<--- openRecorderCompleted: $success');
  }

  @override
  void pauseRecorderCompleted(int? state, bool? success) {
    _logger.d('---> pauseRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    if (success!) {
      _pauseRecorderCompleter!.complete();
    } else {
      _pauseRecorderCompleter!.completeError('pauseRecorder failed');
    }
    _pauseRecorderCompleter = null;
    _logger.d('<--- pauseRecorderCompleted: $success');
  }

  @override
  void recordingData({Uint8List? data}) {
    if (_userStreamSink != null) {
      _userStreamSink!.add(FoodData(data));
    }
  }

  @override
  void resumeRecorderCompleted(int? state, bool? success) {
    _logger.d('---> resumeRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    if (success!) {
      _resumeRecorderCompleter!.complete();
    } else {
      _resumeRecorderCompleter!.completeError('resumeRecorder failed');
    }
    _resumeRecorderCompleter = null;
    _logger.d('<--- resumeRecorderCompleted: $success');
  }

  @override
  void startRecorderCompleted(int? state, bool? success) {
    _logger.d('---> startRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    if (success!) {
      _startRecorderCompleter!.complete();
    } else {
      _startRecorderCompleter!.completeError('startRecorder() failed');
    }
    _startRecorderCompleter = null;
    _logger.d('<--- startRecorderCompleted: $success');
  }

  @override
  void stopRecorderCompleted(int? state, bool? success) {
    _logger.d('---> stopRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    if (success!) {
      _stopRecorderCompleter!.complete();
    } // stopRecorder must not gives errors
    else {
      _stopRecorderCompleter!.completeError('stopRecorder failed');
    }
    _stopRecorderCompleter = null;
    // _cleanCompleters(); ????
    _logger.d('<---- stopRecorderCompleted: $success');
  }
}

class _RecorderException implements Exception {
  final String _message;

  _RecorderException(this._message);

  String get message => _message;
}

class _RecorderRunningException extends _RecorderException {
  _RecorderRunningException(String message) : super(message);
}
