package com.isyaratify.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity — Menyediakan jembatan MethodChannel & EventChannel untuk
 * integrasi kamera Android + MediaPipe Tasks Vision Android (Tugas Anggota 5).
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val METHOD_CHANNEL = "com.isyaratify.app/hand_tracking"
        private const val EVENT_CHANNEL = "com.isyaratify.app/hand_tracking_stream"
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    // Fondasi jembatan siap; Anggota 5 menghubungkan CameraX + MediaPipe
                    // HandLandmarker (hand_landmarker.task) dan mengembalikan textureId.
                    result.error(
                        "NOT_IMPLEMENTED",
                        "Pipeline CameraX + MediaPipe Tasks Vision Android siap dihubungkan pada perangkat uji.",
                        null
                    )
                }
                "stop" -> {
                    result.success(null)
                }
                "dispose" -> {
                    eventSink = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }
}
