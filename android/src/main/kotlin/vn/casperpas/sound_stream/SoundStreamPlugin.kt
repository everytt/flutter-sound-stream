package vn.casperpas.sound_stream

import android.Manifest
import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

/** SoundStreamPlugin */
class SoundStreamPlugin : FlutterPlugin,
        ActivityAware {
    private val logTag = "SoundStreamPlugin"

    private var currentActivity: Activity? = null
    private var pluginContext: Context? = null
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    /** ======== Basic Plugin initialization ======== **/

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        println("[flutter] onAttachedToEngine ++++ : ${flutterPluginBinding?.binaryMessenger}")

        pluginBinding = flutterPluginBinding
        pluginContext = flutterPluginBinding.applicationContext

        onAttachedToEngine(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            println("[flutter] registerWith ++++")
            val plugin = SoundStreamPlugin()
            plugin.currentActivity = registrar.activity()
            plugin.pluginContext = registrar.context()
            plugin.onAttachedToEngine(registrar.context(), registrar.messenger())
            print("[flutter] registerWith -----")

        }
    }

    fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
        pluginContext = applicationContext

        SoundPlayerManager.attachSoundPlayer(pluginContext, messenger)
        SoundRecorderManager.attachRecorder(pluginContext, messenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromActivity() {
//        currentActivity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        println("[flutter] onAttachedToActivity ++++")

        currentActivity = binding.activity

//        SoundPlayerManager.attachSoundPlayer(pluginContext, pluginBinding.binaryMessenger)
//        SoundRecorderManager.attachRecorder(pluginContext, pluginBinding.binaryMessenger)

    }

    override fun onDetachedFromActivityForConfigChanges() {
//        currentActivity = null
    }

}
