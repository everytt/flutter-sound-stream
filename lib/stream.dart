library stream;

import 'dart:async';
import 'dart:typed_data';
import 'player_stream.dart';
import 'package:logger/logger.dart' show Level, Logger;

enum SoundStreamStatus {
  Unset,
  Initialized,
  Playing,
  Stopped,
}

enum Initialized {
  /// The object has been created but is not initialized
  notInitialized,

  /// The object is initialized and can be fully used
  fullyInitialized,
}

/// Food is an abstract class which represents objects that can be sent
/// to a player when playing data from astream or received by a recorder
/// when recording to a Dart Stream.
///
/// This class is extended by
/// - [FoodData] and
/// - [FoodEvent].
abstract class Food {
  /// use internally by Flutter Sound
  Future<void> exec(PlayerStream player);

  /// use internally by Flutter Sound
  void dummy(PlayerStream player) {} // Just to satisfy `dartanalyzer`
}

/// FoodData are the regular objects received from a recorder when recording to a Dart Stream
/// or sent to a player when playing from a Dart Stream
class FoodData extends Food {
  /// the data to be sent (or received)
  Uint8List? data;

  /// The constructor, specifying the data to be sent or that has been received
  /* ctor */ FoodData(this.data);

  /// Used internally by Flutter Sound
  @override
  Future<void> exec(PlayerStream player) => player.feedFromStream(data!);
}

class SoundStream {
  Logger _logger = Logger(level: Level.debug);

  /// The FlutterSound Logger getter
  Logger get logger => _logger;

  /// The FlutterSound Logger setter
  set logger(aLogger) {
    _logger = aLogger;
    // TODO
    // Here we must call flutter_sound_core if necessary
  }

  static final SoundStream _instance = SoundStream._internal();
  factory SoundStream() => _instance;
  SoundStream._internal();

  PlayerStream thePlayer = PlayerStream();
}

String _enumToString(Object o) => o.toString().split('.').last;
