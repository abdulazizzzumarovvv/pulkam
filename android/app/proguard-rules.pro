# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# speech_to_text — Google recognition
-keep class org.pytorch.** { *; }

# Gson / model saqlash (agar reflection ishlatsa)
-keepattributes Signature
-keepattributes *Annotation*

# Umumiy — warning'larni yashirmaslik
-dontwarn io.flutter.embedding.**
