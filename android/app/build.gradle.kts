plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // ضروري جداً لكي يتعرف Gradle على متغيرات flutter
}

android {
    namespace = "com.janbak.delivery"
    compileSdk = flutter.compileSdkVersion
    compileToolsVersion = flutter.buildToolsVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // تفعيل الـ Desugaring لحل مشكلة الإشعارات
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
        multiDexEnabled = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // إضافة مكتبة الـ Desugaring المطلوبة
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}