package vn.casperpas.sound_stream

import android.content.Context
import android.nfc.Tag
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec

class SoundPlayerManager(val ctx: Context?, val messenger: BinaryMessenger) : SoundManager(), MethodChannel.MethodCallHandler {
    var audioPlayer: SoundPlayer? = null
    companion object {
        const val TAG = "[flutter] SoundPlayerManager"
//        var soundPlayerPlugin: SoundPlayerManager? = null
        private var context:Context? = null

//        fun attachSoundPlayer(ctx: Context?, messenger: BinaryMessenger) {
//            Log.d(TAG, "SoundPlayerManager {${hashCode()}} attachSoundPlayer ::::$ctx / $messenger")
////            if (soundPlayerPlugin == null) {
////                soundPlayerPlugin =
////                    SoundPlayerManager()
////                Log.d(TAG, ">> create SoundPlayerManager ")
////            }
//            var channel = MethodChannel(messenger, "vn.casperpas.sound_stream:player")
//            init(channel)
//
//            channel.setMethodCallHandler(this)
//            context = ctx
//        }
    }


    fun initManager() {
        Log.d(TAG, "SoundPlayerManager {${hashCode()}} initManager ::::$ctx / $messenger")
//            if (soundPlayerPlugin == null) {
//                soundPlayerPlugin =
//                    SoundPlayerManager()
//                Log.d(TAG, ">> create SoundPlayerManager ")
//            }
        var channel = MethodChannel(messenger, "vn.casperpas.sound_stream:player")
        init(channel)

        channel.setMethodCallHandler(this)
        context = ctx
    }

    fun destroy() {
        channel?.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        println("[flutter] SoundPlayerManager onMethodCall : ${call.method}")
        when( call.method ) {
            "resetPlugin"-> {
                resetPlugin(call,result)
                return
            }
        }

        audioPlayer = getSession(call) as SoundPlayer?
        when(call.method) {
            "openPlayer" -> {
                audioPlayer = SoundPlayer(call, this)
                initSession(call, audioPlayer!!)
                audioPlayer!!.openPlayer(call, result)
            }
            "closePlayer" -> audioPlayer?.closePlayer(call, result)
            "getPlayerState" -> audioPlayer?.getPlayerState(call, result)
            "startPlayer" -> audioPlayer?.startPlayer(call, result)
            "stopPlayer" -> audioPlayer?.stopPlayer(call, result)
            "pausePlayer" -> audioPlayer?.pausePlayer(call, result)
            "resumePlayer" -> audioPlayer?.resumePlayer(call, result)
            "feed" -> audioPlayer?.feed(call, result)
            "setLogLevel" -> {
                //aPlayer.setLogLevel(call, result)
            }
            else -> result.notImplemented()
        }
    }
}