package com.example.ninja_game

import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.ninja_game/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestBgmFocus" -> requestBgmFocus(result)
                "playSfxNative" -> playSfxNative(call, result)
                "abandonFocus" -> abandonFocus(result)
                else -> result.notImplemented()
            }
        }
    }

    private val audioManager get() = getSystemService(AUDIO_SERVICE) as AudioManager

    private fun requestBgmFocus(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val attrs = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
                val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(attrs)
                    .build()
                audioManager.requestAudioFocus(focusRequest)
            } else {
                @Suppress("DEPRECATION")
                audioManager.requestAudioFocus({}, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    private fun playSfxNative(call: MethodCall, result: MethodChannel.Result) {
        try {
            // 🔥 FIXED: Use Map instead of call.argument for new Flutter versions
            val args = call.arguments as? Map<*, *>
            val path = args?.get("path") as? String ?: return result.error("NO_PATH", null, null)
            val volume = (args?.get("volume") as? Number)?.toFloat() ?: 1.0f

            val afd = this.assets.openFd(path)

            val mediaPlayer = MediaPlayer().apply {
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_GAME)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                setVolume(volume, volume)
                prepare()
                setOnCompletionListener { it.release() }
            }
            mediaPlayer.start()
            afd.close()

            result.success(true)
        } catch (e: Exception) {
            result.error("SFX_ERROR", e.message, null)
        }
    }

    private fun abandonFocus(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN).build()
                audioManager.abandonAudioFocusRequest(focusRequest)
            } else {
                @Suppress("DEPRECATION")
                audioManager.abandonAudioFocus(null)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }
}