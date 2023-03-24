package vn.casperpas.sound_stream

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import io.flutter.plugin.common.StandardMethodCodec


class SoundRecorderManager(val ctx: Context?, val messenger: BinaryMessenger): SoundManager(), MethodChannel.MethodCallHandler{
    var audioRecorder: SoundRecorder? = null

    companion object {
        const val TAG = "SoundRecorderManager"

        var soundRecorderPlugin: SoundRecorderManager? = null

//        fun attachRecorder(ctx: Context?, messenger: BinaryMessenger) {
//            if (soundRecorderPlugin == null) {
//                soundRecorderPlugin =
//                    SoundRecorderManager()
//            }
//            val channel = MethodChannel(messenger, "vn.casperpas.sound_stream:recorder", StandardMethodCodec.INSTANCE, messenger.makeBackgroundTaskQueue())
//
//            init(channel)
//            channel.setMethodCallHandler(this)
//            context = ctx
//        }

    }

    fun initManager() {
        val channel = MethodChannel(messenger, "vn.casperpas.sound_stream:recorder")

        init(channel)
        channel.setMethodCallHandler(this)
    }


    fun destroy() {
        audioRecorder?.closeRecorder(null, null)
        channel?.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
       Log.d(TAG, "[flutter] onMethodCall :::: ${call.method}")

        when (call.method) {
            "resetPlugin" -> {
                resetPlugin(call, result)
                return
            }
        }

        audioRecorder = getSession(call) as SoundRecorder?
        when (call.method) {
            "openRecorder" -> {
                audioRecorder = SoundRecorder(call, this)
                initSession(call, audioRecorder!!)
                audioRecorder?.openRecorder(call, result)
            }
            "closeRecorder" -> {
                audioRecorder?.closeRecorder(call, result)
            }
            "startRecorder" -> {
                audioRecorder?.startRecorder(call, result)
            }
            "stopRecorder" -> {
                audioRecorder?.stopRecorder(call, result)
            }
            "pauseRecorder" -> {
                audioRecorder?.pauseRecorder(call, result)
            }
            "resumeRecorder" -> {
                audioRecorder?.resumeRecorder(call, result)
            }
            "setLogLevel" -> {
//                aRecorder.setLogLevel(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}