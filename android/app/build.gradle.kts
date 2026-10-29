import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
fun signingValue(property: String, environment: String): String? =
    System.getenv(environment)?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(property)?.takeIf { it.isNotBlank() }
val releaseAlias = signingValue("keyAlias", "STORE_SIGNING_KEY_ALIAS")
val releaseKeyPassword = signingValue("keyPassword", "STORE_SIGNING_KEY_PASSWORD")
val releaseStorePath = signingValue("storeFile", "STORE_SIGNING_STORE_FILE")
val releaseStorePassword = signingValue("storePassword", "STORE_SIGNING_STORE_PASSWORD")
val releaseSigningReady = listOf(releaseAlias, releaseKeyPassword, releaseStorePath, releaseStorePassword).all { it != null }
if (!releaseSigningReady && gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }) {
    throw GradleException("Release signing is missing. Provide STORE_SIGNING_* environment variables or an untracked android/key.properties.")
}

android {
    namespace = "com.mahm.doctor_bike"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
        
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mahm.doctor_bike"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
      
    }
    signingConfigs {
        if (releaseSigningReady) {
            create("release") {
                keyAlias = releaseAlias
                keyPassword = releaseKeyPassword
                storeFile = file(releaseStorePath!!)
                storePassword = releaseStorePassword
            }
        }
    }
    buildTypes {
        release {
            if (releaseSigningReady) signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
    dependencies {
    implementation("com.google.android.exoplayer:exoplayer:2.19.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    }
