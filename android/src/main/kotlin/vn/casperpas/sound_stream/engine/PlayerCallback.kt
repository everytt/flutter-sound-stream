package vn.casperpas.sound_stream.engine

import vn.casperpas.sound_stream.Sound

interface PlayerCallback {
    fun openPlayerCompleted(success: Boolean)
    fun closePlayerCompleted(success: Boolean)
    fun stopPlayerCompleted(success: Boolean)
    fun pausePlayerCompleted(success: Boolean)
    fun resumePlayerCompleted(success: Boolean)
    fun startPlayerCompleted(success: Boolean)
    fun needSomeFood(ln: Int)
    fun log(level: Sound.LOG_LEVEL, msg: String)
}