package com.isyaratify.app

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import android.view.Surface
import androidx.camera.core.AspectRatio
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    companion object {
        private const val METHOD_CHANNEL = "com.isyaratify.app/hand_tracking"
        private const val EVENT_CHANNEL = "com.isyaratify.app/hand_tracking_stream"
        private const val CAMERA_PERMISSION_REQUEST_CODE = 1001
        private const val MODEL_ASSET_PATH = "hand_landmarker.task"
        private const val MIN_FRAME_INTERVAL_MS = 66L // Target ~15 FPS
    }

    private var flutterEngineRef: FlutterEngine? = null
    private var eventSink: EventChannel.EventSink? = null
    private var pendingInitResult: MethodChannel.Result? = null

    private var textureEntry: TextureRegistry.SurfaceTextureEntry? = null
    private var previewSurface: Surface? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var handLandmarker: HandLandmarker? = null
    private var cameraExecutor: ExecutorService? = null

    private val isProcessingFrame = AtomicBoolean(false)
    private var lastFrameTimestampMs = 0L
    private var isFrontCamera = true

    private val isoFormatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineRef = flutterEngine

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> handleInitialize(result)
                "stop" -> {
                    stopCameraPipeline()
                    result.success(null)
                }
                "dispose" -> {
                    disposePipeline()
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

    private fun handleInitialize(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED
        ) {
            startCameraAndLandmarker(result)
        } else {
            pendingInitResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CAMERA),
                CAMERA_PERMISSION_REQUEST_CODE
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            val result = pendingInitResult ?: return
            pendingInitResult = null
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startCameraAndLandmarker(result)
            } else {
                result.error(
                    "PERMISSION_DENIED",
                    "Izin kamera ditolak oleh pengguna.",
                    null
                )
            }
        }
    }

    private fun startCameraAndLandmarker(result: MethodChannel.Result) {
        if (cameraExecutor == null || cameraExecutor!!.isShutdown) {
            cameraExecutor = Executors.newSingleThreadExecutor()
        }

        // 1. Inisialisasi MediaPipe HandLandmarker
        if (handLandmarker == null) {
            try {
                val baseOptions = BaseOptions.builder()
                    .setModelAssetPath(MODEL_ASSET_PATH)
                    .build()

                val options = HandLandmarker.HandLandmarkerOptions.builder()
                    .setBaseOptions(baseOptions)
                    .setNumHands(2)
                    .setMinHandDetectionConfidence(0.5f)
                    .setMinHandPresenceConfidence(0.5f)
                    .setMinTrackingConfidence(0.5f)
                    .setRunningMode(RunningMode.LIVE_STREAM)
                    .setResultListener(this::onHandLandmarkerResult)
                    .setErrorListener { error ->
                        runOnUiThread {
                            eventSink?.error(
                                "UNKNOWN",
                                error.message ?: "Kesalahan runtime MediaPipe.",
                                null
                            )
                        }
                    }
                    .build()

                handLandmarker = HandLandmarker.createFromOptions(this, options)
            } catch (e: Exception) {
                result.error(
                    "MODEL_LOAD_FAILED",
                    "Gagal memuat model MediaPipe ($MODEL_ASSET_PATH): ${e.message}",
                    null
                )
                return
            }
        }

        // 2. Siapkan SurfaceTexture untuk widget Texture Flutter
        val engine = flutterEngineRef
        if (engine == null) {
            result.error("CAMERA_UNAVAILABLE", "FlutterEngine belum siap.", null)
            return
        }

        if (textureEntry == null) {
            textureEntry = engine.renderer.createSurfaceTexture()
        }
        val currentTextureEntry = textureEntry!!

        // 3. Jalankan CameraX
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            try {
                val provider = cameraProviderFuture.get()
                cameraProvider = provider
                provider.unbindAll()

                val selector = when {
                    provider.hasCamera(CameraSelector.DEFAULT_FRONT_CAMERA) -> {
                        isFrontCamera = true
                        CameraSelector.DEFAULT_FRONT_CAMERA
                    }
                    provider.hasCamera(CameraSelector.DEFAULT_BACK_CAMERA) -> {
                        isFrontCamera = false
                        CameraSelector.DEFAULT_BACK_CAMERA
                    }
                    else -> {
                        result.error(
                            "CAMERA_UNAVAILABLE",
                            "Tidak ada perangkat kamera yang ditemukan.",
                            null
                        )
                        return@addListener
                    }
                }

                val preview = Preview.Builder()
                    .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                    .build()

                preview.setSurfaceProvider { request ->
                    val surfaceTexture = currentTextureEntry.surfaceTexture()
                    surfaceTexture.setDefaultBufferSize(
                        request.resolution.width,
                        request.resolution.height
                    )
                    previewSurface?.release()
                    val surface = Surface(surfaceTexture)
                    previewSurface = surface
                    request.provideSurface(surface, ContextCompat.getMainExecutor(this)) {
                        surface.release()
                        if (previewSurface == surface) {
                            previewSurface = null
                        }
                    }
                }

                val imageAnalysis = ImageAnalysis.Builder()
                    .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                    .build()

                imageAnalysis.setAnalyzer(cameraExecutor!!) { imageProxy ->
                    processImageProxy(imageProxy)
                }

                provider.bindToLifecycle(this, selector, preview, imageAnalysis)
                result.success(mapOf("textureId" to currentTextureEntry.id()))
            } catch (e: Exception) {
                result.error(
                    "CAMERA_UNAVAILABLE",
                    "Gagal membuka kamera Android: ${e.message}",
                    null
                )
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun processImageProxy(imageProxy: ImageProxy) {
        val nowMs = SystemClock.uptimeMillis()
        if (nowMs - lastFrameTimestampMs < MIN_FRAME_INTERVAL_MS ||
            !isProcessingFrame.compareAndSet(false, true)
        ) {
            imageProxy.close()
            return
        }
        lastFrameTimestampMs = nowMs

        try {
            val landmarker = handLandmarker
            if (landmarker == null) {
                isProcessingFrame.set(false)
                imageProxy.close()
                return
            }

            val bitmapBuffer = Bitmap.createBitmap(
                imageProxy.width,
                imageProxy.height,
                Bitmap.Config.ARGB_8888
            )
            imageProxy.planes[0].buffer.rewind()
            bitmapBuffer.copyPixelsFromBuffer(imageProxy.planes[0].buffer)

            val rotationDegrees = imageProxy.imageInfo.rotationDegrees
            imageProxy.close()

            val matrix = Matrix().apply {
                postRotate(rotationDegrees.toFloat())
                if (isFrontCamera) {
                    postScale(
                        -1f,
                        1f,
                        bitmapBuffer.width / 2f,
                        bitmapBuffer.height / 2f
                    )
                }
            }

            val rotatedBitmap = Bitmap.createBitmap(
                bitmapBuffer,
                0,
                0,
                bitmapBuffer.width,
                bitmapBuffer.height,
                matrix,
                true
            )
            if (rotatedBitmap !== bitmapBuffer) {
                bitmapBuffer.recycle()
            }

            val mpImage = BitmapImageBuilder(rotatedBitmap).build()
            landmarker.detectAsync(mpImage, nowMs)
        } catch (e: Exception) {
            isProcessingFrame.set(false)
            imageProxy.close()
        }
    }

    private fun onHandLandmarkerResult(result: HandLandmarkerResult, input: MPImage) {
        isProcessingFrame.set(false)

        val landmarksPerHand = result.landmarks()
        val worldLandmarksPerHand = result.worldLandmarks()
        val handednesses = result.handednesses()

        val handsList = landmarksPerHand.indices.map { i ->
            val handLandmarks = landmarksPerHand[i]
            val category = handednesses.getOrNull(i)?.firstOrNull()
            val rawSide = category?.categoryName()?.lowercase(Locale.US) ?: "right"
            val side = if (rawSide == "left" || rawSide == "right") rawSide else "right"
            val score = category?.score()?.toDouble()

            val serializedLandmarks = handLandmarks.map { lm ->
                mapOf(
                    "x" to lm.x().toDouble(),
                    "y" to lm.y().toDouble(),
                    "z" to lm.z().toDouble()
                )
            }

            val serializedWorldLandmarks = worldLandmarksPerHand.getOrNull(i)?.map { wlm ->
                mapOf(
                    "x" to wlm.x().toDouble(),
                    "y" to wlm.y().toDouble(),
                    "z" to wlm.z().toDouble()
                )
            }

            val handMap = hashMapOf(
                "handedness" to side,
                "landmarks" to serializedLandmarks
            )
            if (score != null) {
                handMap["handednessScore"] = score
            }
            if (serializedWorldLandmarks != null && serializedWorldLandmarks.size == 21) {
                handMap["worldLandmarks"] = serializedWorldLandmarks
            }
            handMap
        }

        val framePayload = mapOf(
            "timestamp" to synchronized(isoFormatter) { isoFormatter.format(Date()) },
            "hands" to handsList,
            "imageWidth" to input.width,
            "imageHeight" to input.height,
            "isMirrored" to isFrontCamera
        )

        runOnUiThread {
            eventSink?.success(framePayload)
        }
    }

    private fun stopCameraPipeline() {
        try {
            cameraProvider?.unbindAll()
        } catch (e: Exception) {
        }
        isProcessingFrame.set(false)
    }

    private fun disposePipeline() {
        stopCameraPipeline()
        previewSurface?.release()
        previewSurface = null
        textureEntry?.release()
        textureEntry = null

        cameraExecutor?.shutdown()
        cameraExecutor = null

        try {
            handLandmarker?.close()
        } catch (e: Exception) {
        }
        handLandmarker = null
        eventSink = null
    }

    override fun onDestroy() {
        disposePipeline()
        super.onDestroy()
    }
}