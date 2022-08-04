package vn.casperpas.sound_stream

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


open class SoundManager {
    var channel: MethodChannel? = null
    var slots: ArrayList<SoundSession?>? = null

    fun init(aChannel: MethodChannel) {
        if (slots == null) {
            slots = ArrayList()
        }
        channel = aChannel
    }

    fun invokeMethod(methodName: String, dic: Map<String, Any>) {
        channel?.invokeMethod(methodName, dic)
    }

    fun freeSlot(slotNo: Int) {
        slots!![slotNo] = null
    }

    fun getSession(call: MethodCall): SoundSession? {
        val slotNo = call.argument<Int>("slotNo")!!
        if (slotNo < 0 || slotNo > slots!!.size) throw RuntimeException()
        if (slotNo == slots!!.size) {
            slots!!.add(slotNo, null)
        }
        return slots!![slotNo]
    }

    fun initSession(call: MethodCall, aPlayer: SoundSession) {
        val slot = call.argument<Int>("slotNo")!!
        slots!![slot] = aPlayer
        aPlayer.init(slot)
    }

    fun resetPlugin(call: MethodCall?, result: MethodChannel.Result) {
        for (i in slots!!.indices) {
            if (slots!![i] != null) {
                slots!![i]?.reset(call, result)
            }
            slots = ArrayList<SoundSession?>()
        }
        result.success(0)
    }
}
