// Pemilihan implementasi per platform via conditional import.
// Web memakai dart.library.js_interop; Android (dart.library.io) memakai
// implementasi Android. Kode ini sendiri tidak mengimpor dart:io.
export 'hand_tracking_platform_stub.dart'
    if (dart.library.js_interop) 'web/hand_tracking_web.dart'
    if (dart.library.io) 'android/hand_tracking_android.dart';
