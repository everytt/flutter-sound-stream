package vn.casperpas.sound_stream.engine

import android.media.MediaRecorder
import vn.casperpas.sound_stream.Sound

class StreamRecorder (val m_callBack: RecorderCallback) {

    var recorder: RecorderEngine? = null
    var status: Sound.RECORDER_STATE = Sound.RECORDER_STATE.RECORDER_IS_STOPPED

    fun openRecorder(): Boolean {
        m_callBack.openRecorderCompleted(true)
        return true
    }


    fun closeRecorder() {
        stop()
        status = Sound.RECORDER_STATE.RECORDER_IS_STOPPED
        m_callBack.closeRecorderCompleted(true)
    }
    fun getRecorderState(): Sound.RECORDER_STATE? {
        return status
    }

    fun startRecorder(numChannels: Int, sampleRate: Int, audioSource: Int):Boolean {
        stop()

        recorder = RecorderEngine()
        recorder!!.startRecording(numChannels, sampleRate,
            audioSource, this)

        status = Sound.RECORDER_STATE.RECORDER_IS_RECORDING
        m_callBack.startRecorderCompleted(true)
        return true
    }


    fun recordingData(data: ByteArray) {
        m_callBack.recordingData(data)
    }

    private fun stop() {
        try {
            recorder?.stopRecorder()
        } catch (e: Exception) {
        }
        recorder = null
        status = Sound.RECORDER_STATE.RECORDER_IS_STOPPED
    }

    fun stopRecorder() {
        stop()
        m_callBack.stopRecorderCompleted(true)
    }


    fun pauseRecorder() {
        recorder!!.pauseRecorder()
        status = Sound.RECORDER_STATE.RECORDER_IS_PAUSED
        m_callBack.pauseRecorderCompleted(true)
    }

    fun resumeRecorder() {
        recorder!!.resumeRecorder()
        status = Sound.RECORDER_STATE.RECORDER_IS_RECORDING
        m_callBack.resumeRecorderCompleted(true)
    }

    fun logDebug(msg: String) {
        m_callBack.log(Sound.LOG_LEVEL.DBG, msg)
    }


    fun logError(msg: String) {
        m_callBack.log(Sound.LOG_LEVEL.ERROR, msg)
    }
}