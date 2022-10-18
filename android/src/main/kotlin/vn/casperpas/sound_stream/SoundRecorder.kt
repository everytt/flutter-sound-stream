package vn.casperpas.sound_stream

import android.media.MediaRecorder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import vn.casperpas.sound_stream.engine.RecorderCallback
import vn.casperpas.sound_stream.engine.StreamRecorder

class SoundRecorder(call:MethodCall, private val channel: SoundManager) : SoundSession(), RecorderCallback {
    val ERR_UNKNOWN = "ERR_UNKNOWN"
    val ERR_RECORDER_IS_NULL = "ERR_RECORDER_IS_NULL"
    val ERR_RECORDER_IS_RECORDING = "ERR_RECORDER_IS_RECORDING"
    val TAG = "SoundStreamPlugin"

    val m_recorder : StreamRecorder = StreamRecorder(this)

    override fun getPlugin(): SoundManager {
        return channel
    }

    override val status: Int
        get() = m_recorder.getRecorderState()!!.ordinal


    override fun openRecorderCompleted(success: Boolean) {
        invokeMethodWithBoolean("openRecorderCompleted", success, success)
    }

    override fun closeRecorderCompleted(success: Boolean) {
        invokeMethodWithBoolean("closeRecorderCompleted", success, success)
    }

    override fun startRecorderCompleted(success: Boolean) {
        invokeMethodWithBoolean("startRecorderCompleted", success, success)
    }

    override fun stopRecorderCompleted(success: Boolean) {
        invokeMethodWithBoolean("stopRecorderCompleted", success, success)
    }

    override fun pauseRecorderCompleted(success: Boolean) {
        invokeMethodWithBoolean("pauseRecorderCompleted", success, success)
    }

    override fun resumeRecorderCompleted(success: Boolean) {
        invokeMethodWithBoolean("resumeRecorderCompleted", success, success)
    }

    override fun recordingData(data: ByteArray) {
        val dic: MutableMap<String, Any> = HashMap()
        dic["recordingData"] = data
        invokeMethodWithMap("recordingData", true, dic)
    }

    fun openRecorder(call: MethodCall?, result: MethodChannel.Result) {
        val r = m_recorder.openRecorder()
        if (r) {
            result.success("openRecorder")
        } else result.error(
            ERR_UNKNOWN,
            ERR_UNKNOWN,
            "Failure to open session"
        )
    }


    fun startRecorder(call: MethodCall, result: MethodChannel.Result) {
            val sampleRate = call.argument<Int>("sampleRate") ?: 16000
            val numChannels = call.argument<Int>("numChannels")  ?: 1
            val path = call.argument<String>("path")
            val codec = call.argument<Int>("codec")
            val bitRate = call.argument<Int>("bitRate")
            val audioSource = call.argument<Int>("audioSource")
            val toStream = call.argument<Int>("toStream")

            val r: Boolean = m_recorder.startRecorder(
                numChannels,
                sampleRate,
                MediaRecorder.AudioSource.VOICE_CALL
            )
            if (r) result.success("Media Recorder is started") else result.error(
                "startRecorder",
                "startRecorder",
                "Failure to start recorder"
            )
    }


    fun stopRecorder(call: MethodCall?, result: MethodChannel.Result) {
        m_recorder.stopRecorder()
        result.success("Media Recorder is closed")
    }

    fun pauseRecorder(call: MethodCall?, result: MethodChannel.Result) {
        m_recorder.pauseRecorder()
        result.success("Recorder is paused")
    }

    fun resumeRecorder(call: MethodCall?, result: MethodChannel.Result) {
        m_recorder.resumeRecorder()
        result.success("Recorder is resumed")
    }

    fun closeRecorder(call: MethodCall?, result: MethodChannel.Result) {
        m_recorder.closeRecorder()
        result.success("closeRecorder")
    }

    override fun reset(call: MethodCall?, result: MethodChannel.Result?) {
        m_recorder.closeRecorder()
        result!!.success(0)
    }
}