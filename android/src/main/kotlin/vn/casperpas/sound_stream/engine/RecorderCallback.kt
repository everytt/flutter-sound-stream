package vn.casperpas.sound_stream.engine

import vn.casperpas.sound_stream.Sound

interface RecorderCallback {
    fun openRecorderCompleted(success: Boolean)
    fun closeRecorderCompleted(success: Boolean)
    fun startRecorderCompleted(success: Boolean)
    fun stopRecorderCompleted(success: Boolean)
    fun pauseRecorderCompleted(success: Boolean)
    fun resumeRecorderCompleted(success: Boolean)
    fun recordingData(data: ByteArray)
    fun log(level: Sound.LOG_LEVEL, msg: String)
}