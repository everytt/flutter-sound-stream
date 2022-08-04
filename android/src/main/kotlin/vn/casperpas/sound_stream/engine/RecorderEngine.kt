package vn.casperpas.sound_stream.engine

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.nio.ByteBuffer
import java.util.*

class RecorderEngine {
    private var mRecorder: AudioRecord? = null
    private var isRecording: Boolean = false

    private var session: StreamRecorder? = null
    private var p: Runnable? = null
    private val mainHandler = Handler(Looper.getMainLooper())


    private fun writeBuffer(bufferSize: Int) : Int {
        var n = 0
        while (isRecording) {
            val byteBuffer = ByteBuffer.allocate(bufferSize)

            n = if( Build.VERSION.SDK_INT >= 23) {
                mRecorder?.read(byteBuffer.array(), 0, bufferSize, AudioRecord.READ_NON_BLOCKING) !!
            } else {
                mRecorder?.read(byteBuffer.array(), 0, bufferSize) !!
            }
            if( n > 0 ) session?.recordingData(Arrays.copyOfRange(byteBuffer.array(), 0, n))
            else break
        }

        if(isRecording)
            mainHandler?.post(p)
        return n
    }

    fun startRecording(numChannels: Int, sampleRate: Int, audioSource: Int, sSession: StreamRecorder) {
            if (Build.VERSION.SDK_INT < 21) throw Exception("Need at least SDK 21")

            session = sSession
        val channelConfig =
            if (numChannels == 1) AudioFormat.CHANNEL_IN_MONO else AudioFormat.CHANNEL_IN_STEREO

        val bufferSize:Int = AudioRecord.getMinBufferSize(
                sampleRate,
                channelConfig,
                AudioFormat.ENCODING_PCM_16BIT)* 2

            mRecorder = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channelConfig,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSize
            )

            if (mRecorder!!.state == AudioRecord.STATE_INITIALIZED) {
                mRecorder!!.startRecording()
                isRecording = true
                p = Runnable {
                    if(isRecording) {
                        var n:Int = writeBuffer(bufferSize)
                    }
                }
                mainHandler?.post(p)
            } else {
                throw Exception("Cannot initialize the AudioRecord")
            }

    }

    @Throws(Exception::class)
    fun stopRecorder(){
        try {
            mRecorder?.stop()
        } catch (e: java.lang.Exception) {
        }
        try {
            isRecording = false
            mRecorder?.release()
        } catch (e: java.lang.Exception) {
        }
        mRecorder = null
    }

    fun pauseRecorder(): Boolean {
        return try {
            mRecorder!!.stop()
            true
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            false
        }
    }

    fun resumeRecorder(): Boolean {
        return try {
            mRecorder!!.startRecording()
            true
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            false
        }
    }

}