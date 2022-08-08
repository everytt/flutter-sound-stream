package vn.casperpas.sound_stream

import android.content.Context
import android.nfc.Tag
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec

class SoundPlayerManager(val ctx: Context?, val messenger: BinaryMessenger) : SoundManager(), MethodChannel.MethodCallHandler {

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

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        println("[flutter] SoundPlayerManager onMethodCall : ${call.method}")
        when( call.method ) {
            "resetPlugin"-> {
                resetPlugin(call,result)
                return
            }
        }

        var aPlayer = getSession(call) as SoundPlayer?
        when(call.method) {
            "openPlayer" -> {
                aPlayer = SoundPlayer(call, this)
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