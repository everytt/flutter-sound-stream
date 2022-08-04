package vn.casperpas.sound_stream

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import vn.casperpas.sound_stream.engine.PlayerCallback
import vn.casperpas.sound_stream.engine.StreamPlayer

class SoundPlayer(call:MethodCall) : SoundSession(), PlayerCallback {
    val ERR_UNKNOWN = "ERR_UNKNOWN"
    val ERR_PLAYER_IS_NULL = "ERR_PLAYER_IS_NULL"
    val ERR_PLAYER_IS_PLAYING = "ERR_PLAYER_IS_PLAYING"
    val TAG = "SoundStreamPlugin"

    private val m_player: StreamPlayer = StreamPlayer(this)

    override fun openPlayerCompleted(success: Boolean) {
        invokeMethodWithBoolean("openPlayerCompleted", success, success)
    }

    override fun closePlayerCompleted(success: Boolean) {
        invokeMethodWithBoolean("closePlayerCompleted", success, success)
    }

    override fun stopPlayerCompleted(success: Boolean) {
        invokeMethodWithBoolean("stopPlayerCompleted", success, success)
    }

    override fun pausePlayerCompleted(success: Boolean) {
        invokeMethodWithBoolean("pausePlayerCompleted", success, success)
    }

    override fun resumePlayerCompleted(success: Boolean) {
        invokeMethodWithBoolean("resumePlayerCompleted", success, success)
    }

    override fun startPlayerCompleted(success: Boolean) {
        val dico: MutableMap<String, Any> = HashMap()
        dico["state"] = getPlayerState() as Int
        invokeMethodWithMap("startPlayerCompleted", success, dico)
    }

    override fun needSomeFood(ln: Int) {
        invokeMethodWithInteger("needSomeFood", true, ln)
    }

    override fun getPlugin(): SoundManager {
        return SoundPlayerManager.soundPlayerPlugin!!
    }

    override val status: Int
        get() =  m_player.getPlayerState()!!.ordinal

    override fun reset(call: MethodCall?, result: MethodChannel.Result?) {
        m_player.closePlayer()
        result?.success(getPlayerState())
    }
    private fun getPlayerState(): Int {
        return m_player.getPlayerState()!!.ordinal
    }

    fun getPlayerState(call: MethodCall?, result: MethodChannel.Result) {
        result.success(getPlayerState())
    }


    fun openPlayer(call: MethodCall?, result: MethodChannel.Result) {
        val r: Boolean = m_player.openPlayer()
        if (r) {
            result.success(getPlayerState())
        } else result.error(
            ERR_UNKNOWN,
            ERR_UNKNOWN,
            "Failure to open session"
        )
    }

    fun closePlayer(call: MethodCall?, result: MethodChannel.Result) {
        m_player.closePlayer()
        result.success(getPlayerState())
    }


    fun startPlayer(call: MethodCall, result: MethodChannel.Result) {
        var blockSize: Int = call.argument<Int>("blockSize") ?: 4096
        var sampleRate: Int = call.argument<Int>("sampleRate") ?: 16000
        var numChannels: Int = call.argument<Int>("numChannels") ?: 1

        try {
            val b: Boolean = m_player.startPlayer(
                numChannels,
                sampleRate,
                blockSize
            )
            if (b) {
                result.success(getPlayerState())
            } else result.error(
                ERR_UNKNOWN,
                ERR_UNKNOWN,
                "startPlayer() error"
            )
        } catch (e: Exception) {
            log(Sound.LOG_LEVEL.ERROR, "startPlayer() exception")
            result.error(
                ERR_UNKNOWN,
                ERR_UNKNOWN,
                e.message
            )
        }
    }

    fun feed(call: MethodCall, result: MethodChannel.Result) {
        try {
            val data = call.argument<ByteArray>("data")
            val ln: Int = m_player.feed(data!!)
            assert(ln >= 0)
            result.success(ln)
        } catch (e: Exception) {
            log(Sound.LOG_LEVEL.ERROR, "feed() exception")
            result.error(
                ERR_UNKNOWN,
                ERR_UNKNOWN,
                e.message
            )
        }
    }


    fun stopPlayer(call: MethodCall?, result: MethodChannel.Result) {
        m_player.stopPlayer()
        result.success(getPlayerState())
    }


    fun pausePlayer(call: MethodCall?, result: MethodChannel.Result) {
        try {
            if (m_player.pausePlayer()) result.success(getPlayerState()) else result.error(
                ERR_UNKNOWN,
                ERR_UNKNOWN,
                "Pause failure"
            )
        } catch (e: java.lang.Exception) {
            log(Sound.LOG_LEVEL.ERROR, "pausePlay exception: " + e.message)
            result.error(
                ERR_UNKNOWN,
                ERR_UNKNOWN,
                e.message
            )
        }
    }

    fun resumePlayer(call: MethodCall?, result: MethodChannel.Result) {
        try {
            if (m_player.resumePlayer()) result.success(getPlayerState()) else result.error(
                ERR_UNKNOWN,
                ERR_UNKNOWN,
                "Resume failure"
            )
        } catch (e: java.lang.Exception) {
            log(Sound.LOG_LEVEL.ERROR, "mediaPlayer resume: " + e.message)
            result.error(
                ERR_UNKNOWN,
                ERR_UNKNOWN,
                e.message
            )
        }
    }


}