package vn.casperpas.sound_stream

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import io.flutter.plugin.common.StandardMethodCodec


class SoundRecorderManager(val ctx: Context?, val messenger: BinaryMessenger): SoundManager(), MethodChannel.MethodCallHandler{
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

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        Log.d(TAG, "[flutter] onMethodCall :::: ${call.method}")

        when (call.method) {
            "resetPlugin" -> {
                resetPlugin(call, result)
                return
            }
        }

        var aRecorder = getSession(call) as SoundRecorder?
        when (call.method) {
            "openRecorder" -> {
                aRecorder = SoundRecorder(call, this)
                initSession(call, aRecorder)
                aRecorder.openRecorder(call, result)
            }
            "closeRecorder" -> {
                aRecorder!!.closeRecorder(call, result)
            }
            "startRecorder" -> {
                aRecorder!!.startRecorder(call, result)
            }
            "stopRecorder" -> {
                aRecorder!!.stopRecorder(call, result)
            }
            "pauseRecorder" -> {
                aRecorder!!.pauseRecorder(call, result)
            }
            "resumeRecorder" -> {
                aRecorder!!.resumeRecorder(call, result)
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