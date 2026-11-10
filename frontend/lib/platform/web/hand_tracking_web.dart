import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import '../../core/errors/app_exceptions.dart';
import '../../models/hand_landmark_model.dart';
import '../../services/hand_tracking_service.dart';

@JS('isyaratifyHandTracking')
external _JSHandTrackingBridge? get _jsBridge;

extension type _JSHandTrackingBridge._(JSObject _) implements JSObject {
  external JSObject ensureContainerElements(JSString containerId);
  external JSPromise<JSAny?> initialize(JSString containerId);
  external void start(JSFunction onFrameJson, JSFunction onError);
  external void stop();
  external void dispose();
}

/// Implementasi Web (`getUserMedia` + MediaPipe Tasks Vision JS via JS interop,
/// `web/hand_tracking_web.js`).
class WebHandTrackingService implements HandTrackingService {
  WebHandTrackingService() : _viewId = _nextId++ {
    _registerViewFactory();
  }

  static int _nextId = 1;
  final int _viewId;
  bool _viewFactoryRegistered = false;
  StreamController<HandLandmarkFrame>? _controller;

  String get _viewType => 'isyaratify-web-camera-$_viewId';
  String get _containerId => 'isyaratify-camera-container-$_viewId';

  void _registerViewFactory() {
    if (_viewFactoryRegistered) return;
    _viewFactoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final bridge = _jsBridge;
      if (bridge == null) {
        throw const HandTrackingException(
          'Script hand_tracking_web.js belum dimuat pada halaman Web.',
          code: HandTrackingErrorCode.notImplemented,
        );
      }
      return bridge.ensureContainerElements(_containerId.toJS);
    });
  }

  @override
  Future<void> initialize() async {
    final bridge = _jsBridge;
    if (bridge == null) {
      throw const HandTrackingException(
        'Script hand_tracking_web.js belum dimuat pada halaman Web.',
        code: HandTrackingErrorCode.notImplemented,
      );
    }
    try {
      await bridge.initialize(_containerId.toJS).toDart;
    } catch (e) {
      throw _mapJsError(e);
    }
  }

  @override
  Stream<HandLandmarkFrame> start() {
    final bridge = _jsBridge;
    if (bridge == null) {
      return Stream<HandLandmarkFrame>.error(
        const HandTrackingException(
          'Script hand_tracking_web.js belum dimuat.',
          code: HandTrackingErrorCode.notImplemented,
        ),
      );
    }

    _controller?.close();
    final controller = StreamController<HandLandmarkFrame>.broadcast(
      onCancel: () {
        bridge.stop();
      },
    );
    _controller = controller;

    void onFrame(JSString jsonStr) {
      if (controller.isClosed) return;
      try {
        final decoded = jsonDecode(jsonStr.toDart);
        final frame = HandLandmarkFrame.fromJson(
          decoded,
          resolveDuplicateSides: true,
        );
        controller.add(frame);
      } catch (err) {
        controller.addError(
          HandTrackingException(
            'Data landmark Web tidak valid: $err',
            code: HandTrackingErrorCode.unknown,
          ),
        );
      }
    }

    void onError(JSString message) {
      if (controller.isClosed) return;
      controller.addError(
        HandTrackingException(
          message.toDart,
          code: HandTrackingErrorCode.unknown,
        ),
      );
    }

    bridge.start(onFrame.toJS, onError.toJS);
    return controller.stream;
  }

  @override
  Future<void> stop() async {
    _jsBridge?.stop();
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<void> dispose() async {
    _jsBridge?.dispose();
    await _controller?.close();
    _controller = null;
  }

  @override
  Widget buildPreview(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }

  HandTrackingException _mapJsError(Object error) {
    final raw = error.toString();
    if (raw.contains('PERMISSION_DENIED') ||
        raw.contains('NotAllowedError') ||
        raw.contains('PermissionDeniedError')) {
      return const HandTrackingException(
        'Izin akses kamera ditolak pada browser.',
        code: HandTrackingErrorCode.permissionDenied,
      );
    }
    if (raw.contains('INSECURE_CONTEXT')) {
      return const HandTrackingException(
        'Akses kamera Web memerlukan HTTPS atau localhost.',
        code: HandTrackingErrorCode.insecureContext,
      );
    }
    if (raw.contains('MODEL_LOAD_FAILED')) {
      return const HandTrackingException(
        'Gagal memuat model MediaPipe Hand Landmarker di browser.',
        code: HandTrackingErrorCode.modelLoadFailed,
      );
    }
    if (raw.contains('CAMERA_UNAVAILABLE') || raw.contains('NotFoundError')) {
      return const HandTrackingException(
        'Perangkat kamera tidak ditemukan atau tidak tersedia.',
        code: HandTrackingErrorCode.cameraUnavailable,
      );
    }
    return HandTrackingException(
      'Gagal menyiapkan kamera Web: $raw',
      code: HandTrackingErrorCode.unknown,
    );
  }
}

HandTrackingService createPlatformHandTrackingService() =>
    WebHandTrackingService();
