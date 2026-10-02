plugins {
    id("com.android.application")
    id("kotlin-android")
    // إذا كنت تستخدم Google Services (مثل Firebase) اتركها مفعلة أو حسب إعدادات مشروعك
    id("com.google.gms.google-services")
}

android {
    namespace = "com.janbak.delivery"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // تم تفعيل الـ Desugaring هنا لحل مشكلة flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.janbak.delivery"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        isMultiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: إضافة إعدادات التوقيع (Signing Configs) الخاصة بك هنا إذا لزم الأمر
            signingConfig = signingConfigs.getByName("debug") // أو ربطه بملف التوقيع الخاص بالإنتاج
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // إضافة مكتبة الـ Desugaring المطلوبة لـ flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}