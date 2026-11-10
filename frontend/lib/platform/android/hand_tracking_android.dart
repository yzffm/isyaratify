import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/errors/app_exceptions.dart';
import '../../models/hand_landmark_model.dart';
import '../../services/hand_tracking_service.dart';

/// Adapter Android berbasis MethodChannel & EventChannel (ADR 0002).
///
/// Menghubungkan Flutter dengan pipeline native Android (CameraX + MediaPipe
/// Tasks Vision Android di `MainActivity.kt`).
class AndroidHandTrackingService implements HandTrackingService {
  AndroidHandTrackingService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ??
           const MethodChannel('com.isyaratify.app/hand_tracking'),
       _eventChannel =
           eventChannel ??
           const EventChannel('com.isyaratify.app/hand_tracking_stream');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  int? _textureId;

  @override
  Future<void> initialize() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'initialize',
      );
      final rawTextureId = result?['textureId'];
      if (rawTextureId is int) {
        _textureId = rawTextureId;
      }
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } on MissingPluginException {
      throw const HandTrackingException.notImplemented('Android');
    }
  }

  @override
  Stream<HandLandmarkFrame> start() {
    try {
      return _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) {
            final Object? payload = event is String ? jsonDecode(event) : event;
            return HandLandmarkFrame.fromJson(
              payload,
              resolveDuplicateSides: true,
            );
          })
          .handleError((Object error) {
            if (error is PlatformException) {
              throw _mapPlatformException(error);
            }
            if (error is HandTrackingException) {
              throw error;
            }
            throw HandTrackingException(
              'Kesalahan stream hand tracking Android: $error',
              code: HandTrackingErrorCode.unknown,
            );
          });
    } on MissingPluginException {
      return Stream<HandLandmarkFrame>.error(
        const HandTrackingException.notImplemented('Android'),
      );
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _methodChannel.invokeMethod<void>('stop');
    } on PlatformException {
      // Abaikan kegagalan stop saat pelepasan kamera
    } on MissingPluginException {
      // Abaikan bila channel belum terdaftar pada test
    }
  }

  @override
  Future<void> dispose() async {
    _textureId = null;
    try {
      await _methodChannel.invokeMethod<void>('dispose');
    } on PlatformException {
      // Abaikan kegagalan dispose
    } on MissingPluginException {
      // Abaikan bila channel belum terdaftar pada test
    }
  }

  @override
  Widget buildPreview(BuildContext context) {
    final textureId = _textureId;
    if (textureId != null) {
      return Texture(textureId: textureId);
    }
    return const ColoredBox(
      color: Color(0xFF111827),
      child: Center(
        child: Icon(Icons.videocam, color: Colors.white54, size: 48),
      ),
    );
  }

  HandTrackingException _mapPlatformException(PlatformException e) {
    final code = switch (e.code) {
      'PERMISSION_DENIED' => HandTrackingErrorCode.permissionDenied,
      'CAMERA_UNAVAILABLE' => HandTrackingErrorCode.cameraUnavailable,
      'MODEL_LOAD_FAILED' => HandTrackingErrorCode.modelLoadFailed,
      'NOT_IMPLEMENTED' => HandTrackingErrorCode.notImplemented,
      _ => HandTrackingErrorCode.unknown,
    };
    return HandTrackingException(
      e.message ?? 'Hand tracking Android belum siap (${e.code}).',
      code: code,
    );
  }
}

HandTrackingService createPlatformHandTrackingService() =>
    AndroidHandTrackingService();
