plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}
val hasReleaseSigning =
    keystoreProperties["keyAlias"] != null &&
        keystoreProperties["keyPassword"] != null &&
        keystoreProperties["storeFile"] != null &&
        keystoreProperties["storePassword"] != null

android {
    namespace = "com.coastalrealtyservices.residentportal"
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
        applicationId = "com.coastalrealtyservices.residentportal"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAlias = keystoreProperties["keyAlias"] as String?
            val keyPassword = keystoreProperties["keyPassword"] as String?
            val storeFilePath = keystoreProperties["storeFile"] as String?
            val storePassword = keystoreProperties["storePassword"] as String?

            if (
                keyAlias != null &&
                keyPassword != null &&
                storeFilePath != null &&
                storePassword != null
            ) {
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                this.storeFile = rootProject.file(storeFilePath)
                this.storePassword = storePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseSigning) signingConfigs.getByName("release")
                else signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

afterEvaluate {
    if (!hasReleaseSigning) {
        tasks.matching { it.name in setOf("bundleRelease", "assembleRelease") }.configureEach {
            doFirst {
                throw GradleException(
                    "Missing Android release signing. Create android/key.properties " +
                        "(see android/key.properties.example) before building release."
                )
            }
        }
    }
}
