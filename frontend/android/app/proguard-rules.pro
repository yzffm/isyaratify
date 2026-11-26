# Flutter wrapper & engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.isyaratify.app.** { *; }

# MediaPipe Tasks Vision & JNI reflection classes
-keep class com.google.mediapipe.** { *; }
-keep interface com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Protobuf (used internally by MediaPipe Tasks calculator graphs)
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# CameraX & Guava ListenableFuture
-keep class androidx.camera.** { *; }
-keep interface androidx.camera.** { *; }
-dontwarn androidx.camera.**
-keep class com.google.common.util.concurrent.** { *; }
-dontwarn com.google.common.util.concurrent.**

# Keep all native JNI methods and @Keep annotated classes/members
-keep @androidx.annotation.Keep class * { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}
