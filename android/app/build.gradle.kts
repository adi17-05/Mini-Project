plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = 35  // You can also use flutter.compileSdkVersion

    ndkVersion = "27.0.12077973" // Match with the latest required version

    defaultConfig {
        applicationId = "com.example.flutter_application_1"

        // ✅ Required for Health Connect
        minSdk = 28

        targetSdk = 34  // Or flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ Health Connect API
    implementation("androidx.health.connect:connect-client:1.1.0-alpha04")

    // ✅ Required for lifecycleScope in Kotlin
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
}

flutter {
    source = "../.."
}
