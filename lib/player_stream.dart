part of sound_stream;

const _blockSize = 4096;

class PlayerStream {
  static final PlayerStream _instance = PlayerStream._internal();
  factory PlayerStream() => _instance;

  final _playerStatusController = StreamController<SoundStreamStatus>.broadcast();
  final _audioStreamController = StreamController<Uint8List>();

  Completer<int>? _needSomeDataCompleter;

  PlayerStream._internal() {
    SoundStream();
    _eventsStreamController.stream.listen(_eventListener);
    _playerStatusController.add(SoundStreamStatus.Unset);
    _audioStreamController.stream.listen((data) {
      writeChunk(data);
    });
  }

  /// Initialize Player with specified [sampleRate]
  Future<dynamic> initialize({int sampleRate = 16000, bool showLogs = false}) => _methodChannel.invokeMethod("initializePlayer", {
        "sampleRate": sampleRate,
        "showLogs": showLogs,
      });

  /// Player will start receiving audio chunks (PCM 16bit data)
  /// to audiostream as Uint8List to play audio.
  Future<dynamic> start() => _methodChannel.invokeMethod("startPlayer");

  /// Player will stop receiving audio chunks.
  Future<dynamic> stop() {
    _needSomeDataCompleter = null;
    return _methodChannel.invokeMethod("stopPlayer");
  }

  Future<void> feedFromStream(Uint8List buffer) async {
    await _feedFromStream(buffer);
  }

  Future<void> _feedFromStream(Uint8List buffer) async {
    var lnData = 0;
    var totalLength = buffer.length;
    while (totalLength > 0 && !(status == SoundStreamStatus.Stopped)) {
      var bsize = totalLength > _blockSize ? _blockSize : totalLength;
      var ln = await _feed(buffer.sublist(lnData, lnData + bsize));
      assert(ln >= 0);
      lnData += ln;
      totalLength -= ln;
    }
  }

  Future<int> _feed(Uint8List data) async {
    if (status != SoundStreamStatus.Initialized) {
      throw Exception("Player is not open");
    } else if (status == SoundStreamStatus.Stopped) {
      return 0;
    }

    _needSomeDataCompleter = Completer<int>();
    try {
      var ln = await feed(data);
      assert(ln >= 0); // feedFromStream() is not happy if < 0
      if (ln != 0) {
        _needSomeDataCompleter = null;
        return (ln);
      }
    } on Exception {
      _needSomeDataCompleter = null;
      if (status == SoundStreamStatus.Stopped) {
        return 0;
      }
      rethrow;
    }

    if (_needSomeDataCompleter != null) {
      return _needSomeDataCompleter!.future;
    }
    return 0;
  }

  Future<int> feed(Uint8List data) async => await _methodChannel.invokeMethod("feed", <String, dynamic>{"data": data}) as int;

  /// Push audio [data] (PCM 16bit data) to player buffer as Uint8List
  /// to play audio. Chunks will be queued/scheduled to play sequentially
  Future<dynamic> writeChunk(Uint8List data) => _methodChannel.invokeMethod("writeChunk", <String, dynamic>{"data": data});

  /// Current status of the [PlayerStream]
  Stream<SoundStreamStatus> get status => _playerStatusController.stream;

  /// Stream's sink to receive PCM 16bit data to send to Player
  StreamSink<Uint8List> get audioStream => _audioStreamController.sink;

  void _eventListener(dynamic event) {
    if (event == null) return;
    final String eventName = event["name"] ?? "";
    switch (eventName) {
      case "playerStatus":
        final String status = event["data"] ?? "Unset";
        _playerStatusController.add(SoundStreamStatus.values.firstWhere(
          (value) => _enumToString(value) == status,
          orElse: () => SoundStreamStatus.Unset,
        ));
        break;
      case "needSomeData":
        needSomeData(event["data"]);
        break;
    }
  }

  void needSomeData(int ln) {
    assert(ln >= 0);
    _needSomeDataCompleter?.complete(ln);
  }

  /// Stop and close all streams. This cannot be undone
  /// Only call this method if you don't want to use this anymore
  void dispose() {
    stop();
    _eventsStreamController.close();
    _playerStatusController.close();
    _audioStreamController.close();
  }
}
