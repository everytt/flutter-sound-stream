package vn.casperpas.sound_stream.engine

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.os.Build

class PlayerEngine {

    private var audioTrack: AudioTrack? = null
    private var mBlockThread: WriteBlockThread? = null
    private var session: StreamPlayer? = null

    inner class WriteBlockThread(data: ByteArray) : Thread() {
        var mData: ByteArray = data
        override fun run() {
            var ln = mData!!.size
            var total = 0
            var written = 0
            while (audioTrack != null && ln > 0) {
                try {
                    written = if (Build.VERSION.SDK_INT >= 23) {
                        audioTrack!!.write(mData, 0, ln, AudioTrack.WRITE_BLOCKING)
                    } else {
                        audioTrack!!.write(mData, 0, mData!!.size)
                    }
                    if (written > 0) {
                        ln -= written
                        total += written
                    }
                } catch (e: Exception) {
//                    debugLog(e.toString())
                    return
                }
            }
            if (total < 0) throw RuntimeException()
            session?.needSomeFood(total)
            mBlockThread = null
        }

    }

    fun startPlayer(sampleRate:Int, numChannel:Int, blockSize:Int, sSession: StreamPlayer) {
        if(Build.VERSION.SDK_INT >= 21) {
            val audioAttributes = AudioAttributes.Builder()
            .setLegacyStreamType(AudioManager.STREAM_VOICE_CALL)
            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
            .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
            .build()

            session = sSession
            val channelMask = if(numChannel == 1) AudioFormat.CHANNEL_OUT_MONO else AudioFormat.CHANNEL_OUT_STEREO
            val playerFormat: AudioFormat = AudioFormat.Builder()
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setChannelMask(channelMask)
                .setSampleRate(sampleRate)
                .build()

        audioTrack = AudioTrack(audioAttributes, playerFormat, blockSize, AudioTrack.MODE_STREAM, AudioManager.AUDIO_SESSION_ID_GENERATE)
            //callback
        session?.onPrepared()
        } else {
            throw Exception("Need SDK 21")
        }
    }

    fun play() {
        audioTrack?.play()
    }

    fun stop() {
        audioTrack?.stop()
        audioTrack?.release()
        audioTrack = null

        mBlockThread = null
    }


    fun pausePlayer() {
        audioTrack!!.pause()
    }


    fun resumePlayer() {
        audioTrack!!.play()
    }

    fun isPlaying(): Boolean {
        return audioTrack!!.playState == AudioTrack.PLAYSTATE_PLAYING
    }


    fun feed(chunk: ByteArray):Int {
        val ln: Int = if (Build.VERSION.SDK_INT >= 23) {
            audioTrack?.write(chunk, 0, AudioTrack.WRITE_NON_BLOCKING)!!
        } else
            0

        if (ln == 0) {
            if (mBlockThread != null) {
                println("Audio packet lost !!!")
            }
//
            mBlockThread = WriteBlockThread(chunk)
            mBlockThread?.start()
        }
        return ln
    }





}