# Keep Razorpay classes
-keep class com.razorpay.** {*;}
-keep class org.json.** { *; }

# ProGuard annotations
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Keep classes that are referenced by Razorpay
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers

# Google Play Core and Split Install
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.**  { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all public classes and their public methods
-keep public class * {
    public protected *;
}

# Gson specific classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.google.gson.** { *; }

# Generic rules for common libraries
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Keep annotation default values (e.g., retrofit2.http.Field.encoded)
-keepattributes AnnotationDefault