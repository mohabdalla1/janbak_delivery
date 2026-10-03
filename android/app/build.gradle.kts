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
    namespace = "com.janbak.delivery"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        // اسم الحزمة الجديد لتجاوز ذاكرة التثبيت المعطوبة على الهاتف
        applicationId = "com.janbak.delivery.app"
        // رفع minSdk صراحة إلى 21 لتوافقية Firebase و MultiDex
=======
        // مطابقة التسمية مع ملف google-services.json لمنع خطأ البناء
        applicationId = "com.janbak.delivery"
>>>>>>> 30d59b8f77648597e8c4bfdeb8a700dc065ec081
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
<<<<<<< HEAD
            // توقيع نسخة الـ Release بمفتاح الـ Debug الافتراضي للتثبيت المباشر
=======
            // إجبار نسخة الـ Release على الاستفادة من مفتاح توقيع ה-debug الافتراضي للتثبيت المباشر
>>>>>>> 30d59b8f77648597e8c4bfdeb8a700dc065ec081
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
