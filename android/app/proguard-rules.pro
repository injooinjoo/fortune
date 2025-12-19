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

# Keep Google Play Core classes (for deferred components and split install)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Stripe push provisioning classes
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Keep TossPay classes
-keep class com.tosspayments.** { *; }

# Keep AdMob classes
-keep class com.google.android.gms.ads.** { *; }

# Keep In-App Purchase / Billing classes
-keep class com.android.vending.billing.** { *; }
-keep class com.google.android.gms.internal.play_billing.** { *; }
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# Keep Flutter In-App Purchase Plugin
-keep class io.flutter.plugins.inapppurchase.** { *; }
-dontwarn io.flutter.plugins.inapppurchase.**

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