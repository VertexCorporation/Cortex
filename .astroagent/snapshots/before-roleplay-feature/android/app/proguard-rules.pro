# main
-keep class com.vertex.cortex.** { *; }

# llama.cpp
-keep class android.llama.cpp.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# JNI
-keepclassmembers class * {
    native <methods>;
}

# Kotlin Companion Objects
-keepclassmembers class * {
    public static ** Companion;
}