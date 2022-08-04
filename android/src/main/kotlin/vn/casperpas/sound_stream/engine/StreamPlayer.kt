package vn.casperpas.sound_stream.engine

import android.os.Handler
import android.os.Looper
import vn.casperpas.sound_stream.Sound

class StreamPlayer(val m_callback: PlayerCallback) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var player: PlayerEngine? = null
    var playerStatus = Sound.PLAYER_STATE.PLAYER_IS_STOPPED
    var pauseMode: Boolean = false

    fun openPlayer() :Boolean {
        playerStatus = Sound.PLAYER_STATE.PLAYER_IS_STOPPED
        m_callback.openPlayerCompleted(true)
        return true
    }

    fun closePlayer() {
        stop()
        playerStatus = Sound.PLAYER_STATE.PLAYER_IS_STOPPED
        mainHandler.post {
            m_callback.closePlayerCompleted(true)
        }
    }

    fun getPlayerState(): Sound.PLAYER_STATE {
        if (player == null) return Sound.PLAYER_STATE.PLAYER_IS_STOPPED
        if (player!!.isPlaying()) {
            if (pauseMode) throw RuntimeException()
            return Sound.PLAYER_STATE.PLAYER_IS_PLAYING
        }
        return if (pauseMode) Sound.PLAYER_STATE.PLAYER_IS_PAUSED else Sound.PLAYER_STATE.PLAYER_IS_STOPPED
    }

    fun onPrepared() {
        logDebug("mediaPlayer prepared and started")
//        mainHandler.post(object : Runnable() {
//            @Override
//            fun run() {
//                var duration: Long = 0
//                try {
//                    duration = player._getDuration()
//                } catch (e: Exception) {
//                    System.out.println(e.toString())
//                }
        playerStatus = Sound.PLAYER_STATE.PLAYER_IS_PLAYING
        m_callback.startPlayerCompleted(true)
//            }
//        })
        /*
		 * Set timer task to send event to RN.
		 */
    }

    fun startPlayer(
        numChannels: Int,
        sampleRate: Int,
        blockSize: Int
    ): Boolean {
        stop() // To start a new clean playback

        try {
            player = PlayerEngine()
            player?.startPlayer(sampleRate, numChannels, blockSize, this)
            play()
        } catch (e: Exception) {
            logError("startPlayer() exception")
            return false
        }
        return true
    }

    private fun play() : Boolean {
        if(player == null) {
            return false
        }

        player!!.play()
        return true

    }

    private fun stop() {
        player?.stop()
        player = null
    }

    fun stopPlayer() {
        stop()
        playerStatus = Sound.PLAYER_STATE.PLAYER_IS_STOPPED
        m_callback.stopPlayerCompleted(true)
    }


    fun pausePlayer(): Boolean {
        return try {
            if (player == null) {
                m_callback.resumePlayerCompleted(false)
                return false
            }
            player?.pausePlayer()
            pauseMode = true
            playerStatus = Sound.PLAYER_STATE.PLAYER_IS_PAUSED
            m_callback.pausePlayerCompleted(true)
            true
        } catch (e: Exception) {
            logError("pausePlay exception: " + e.message)
            false
        }
    }


    fun resumePlayer(): Boolean {
        return try {
            if (player == null) {
                return false
            }
            player!!.resumePlayer()
            pauseMode = false
            playerStatus = Sound.PLAYER_STATE.PLAYER_IS_PLAYING
            m_callback.resumePlayerCompleted(true)
            true
        } catch (e: Exception) {
            logError("mediaPlayer resume: " + e.message)
            false
        }
    }

    @Throws(Exception::class)
    fun feed(data: ByteArray): Int {
        if (player == null) {
            throw Exception("feed() : player is null")
        }
        return try {
            val ln: Int = player!!.feed(data)
            assert(ln >= 0)
            ln
        } catch (e: Exception) {
            logError("feed() exception")
            throw e
        }
    }

    fun needSomeFood(ln: Int) {
        if (ln < 0) throw RuntimeException()
        mainHandler.post { m_callback.needSomeFood(ln) }
    }


    fun logDebug(msg: String) {
        m_callback.log(Sound.LOG_LEVEL.DBG, msg)
    }

    fun logError(msg: String) {
        m_callback.log(Sound.LOG_LEVEL.ERROR, msg)
    }


}