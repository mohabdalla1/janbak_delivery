plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // يجب أن يطابق تماماً مكان ملف MainActivity.kt لعدم حدوث انهيار عند الفتح
    namespace = "com.janbak.delivery"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // تفعيل الـ Desugaring لحل مشاكل التوافق والإشعارات
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // اسم الحزمة الجديد لتجاوز ذاكرة التثبيت المعطوبة على الهاتف
        applicationId = "com.janbak.delivery.app"
        // رفع minSdk صراحة إلى 21 لتوافقية Firebase و MultiDex
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // توقيع نسخة الـ Release بمفتاح الـ Debug الافتراضي للتثبيت المباشر
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // مكتبة الـ Desugaring للميزات الحديثة والإشعارات
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}