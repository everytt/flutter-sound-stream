package vn.casperpas.sound_stream

import android.app.Activity
import android.content.Context

class Sound {
    enum class PLAYER_STATE {
        PLAYER_IS_STOPPED, PLAYER_IS_PLAYING, PLAYER_IS_PAUSED
    }


    enum class RECORDER_STATE {
        RECORDER_IS_STOPPED, RECORDER_IS_PAUSED, RECORDER_IS_RECORDING
    }

    enum class LOG_LEVEL {
        VERBOSE, DBG, INFO, WARNING, ERROR, WTF, NOTHING
    }

    var androidActivity: Activity? = null
    var androidContext: Context? = null
}