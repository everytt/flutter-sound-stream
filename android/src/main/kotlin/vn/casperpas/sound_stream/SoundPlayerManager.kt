package vn.casperpas.sound_stream

import android.content.Context
import android.nfc.Tag
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SoundPlayerManager private constructor() : SoundManager(), MethodChannel.MethodCallHandler {

    companion object {
        const val TAG = "SoundPlayerManager"
        var soundPlayerPlugin: SoundPlayerManager? = null
        private var context:Context? = null

        fun attachSoundPlayer(ctx: Context?, messenger: BinaryMessenger) {
            Log.d(TAG, "[flutter] attachSoundPlayer ::::$ctx / $messenger")
            if (soundPlayerPlugin == null) {
                soundPlayerPlugin =
                    SoundPlayerManager()
            }
            var channel = MethodChannel(messenger, "vn.casperpas.sound_stream:methods")
            soundPlayerPlugin?.init(channel)
            channel.setMethodCallHandler(soundPlayerPlugin)
            context = ctx
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when( call.method ) {
            "resetPlugin"-> {
                resetPlugin(call,result)
                return
            }
        }

        var aPlayer = getSession(call) as SoundPlayer?
        when(call.method) {
            "openPlayer" -> {
                aPlayer = SoundPlayer(call)
                initSession(call, aPlayer)
                aPlayer.openPlayer(call, result)
            }
            "closePlayer" -> aPlayer?.closePlayer(call, result)
            "getPlayerState" -> aPlayer?.getPlayerState(call, result)
            "startPlayer" -> aPlayer?.startPlayer(call, result)
            "stopPlayer" -> aPlayer?.stopPlayer(call, result)
            "pausePlayer" -> aPlayer?.pausePlayer(call, result)
            "resumePlayer" -> aPlayer?.resumePlayer(call, result)
            "feed" -> aPlayer?.feed(call, result)
            "setLogLevel" -> {
                //aPlayer.setLogLevel(call, result)
            }
            else -> result.notImplemented()
        }
    }
}