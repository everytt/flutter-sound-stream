package vn.casperpas.sound_stream

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


abstract class SoundSession {
    var slotNo = 0
    fun init(slot: Int) {
        slotNo = slot
    }
    abstract fun getPlugin(): SoundManager

    fun releaseSession() {
        getPlugin().freeSlot(slotNo)
    }

    abstract val status: Int

    abstract fun reset(call: MethodCall?, result: MethodChannel.Result?)

    fun invokeMethodWithString(methodName: String, success: Boolean, arg: String) {
        val dic: MutableMap<String, Any> = HashMap()
        dic["slotNo"] = slotNo
        dic["state"] = status
        dic["arg"] = arg
        dic["success"] = success
        getPlugin().invokeMethod(methodName, dic)
    }

    fun invokeMethodWithDouble(methodName: String, success: Boolean, arg: Double) {
        val dic: Map<String, Any> =
            mapOf<String, Any>("slotNo" to slotNo, "state" to status, "arg" to arg,"success" to success)
//        dic["slotNo"] = slotNo
//        dic["state"] = status
//        dic["arg"] = arg
//        dic["success"] = success
        getPlugin().invokeMethod(methodName, dic)
    }

    fun invokeMethodWithInteger(methodName: String, success: Boolean, arg: Int) {
        val dic: MutableMap<String, Any> = HashMap()
        dic["slotNo"] = slotNo
        dic["state"] = status
        dic["arg"] = arg
        dic["success"] = success
        getPlugin().invokeMethod(methodName, dic)
    }

    fun invokeMethodWithBoolean(methodName: String, success: Boolean, arg: Boolean) {
        val dic: MutableMap<String, Any> = HashMap()
        dic["slotNo"] = slotNo
        dic["state"] = status
        dic["arg"] = arg
        dic["success"] = success

        getPlugin().invokeMethod(methodName, dic)
    }

    fun invokeMethodWithMap(methodName: String, success: Boolean, dic: MutableMap<String, Any>) {
        dic["slotNo"] = slotNo
        dic["state"] = status
        dic["success"] = success
        getPlugin().invokeMethod(methodName, dic)
    }

    fun log(level: Sound.LOG_LEVEL, msg: String) {
        val dic: MutableMap<String, Any> = HashMap()
        dic["slotNo"] = slotNo
        dic["state"] = status
        dic["level"] = level.ordinal
        dic["msg"] = msg
        dic["success"] = true
        getPlugin().invokeMethod("log", dic)
    }
}
