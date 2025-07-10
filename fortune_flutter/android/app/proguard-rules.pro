# Flutter ProGuard rules
# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep Google Sign-In classes
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep Supabase classes
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }

# Keep Stripe classes
-keep class com.stripe.** { *; }

# Keep TossPay classes
-keep class com.tosspayments.** { *; }

# Keep AdMob classes
-keep class com.google.android.gms.ads.** { *; }

# Keep all annotations
-keepattributes *Annotation*

# Keep all exceptions
-keepattributes Exceptions

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep JavaScript interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# General Android rules
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Preserve reflection methods
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}