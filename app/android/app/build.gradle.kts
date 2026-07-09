import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma de release: local vía android/key.properties; CI vía variables de
// entorno (ANDROID_KEYSTORE_PATH / _PASSWORD / _KEY_ALIAS / _KEY_PASSWORD).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun firma(clave: String, env: String): String? =
    keystoreProperties.getProperty(clave) ?: System.getenv(env)

android {
    namespace = "com.thewiche.antidescuadre"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications requiere desugaring de la librería core
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.thewiche.antidescuadre"
        // camera y gal requieren API 21+; fijamos 23 para galería moderna
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val ruta = firma("storeFile", "ANDROID_KEYSTORE_PATH")
            if (ruta != null) {
                storeFile = file(ruta)
                storePassword = firma("storePassword", "ANDROID_KEYSTORE_PASSWORD")
                keyAlias = firma("keyAlias", "ANDROID_KEY_ALIAS")
                keyPassword = firma("keyPassword", "ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Si hay keystore configurado, firma release; si no, cae a debug
            // para que `flutter run --release` siga funcionando en local.
            signingConfig = if (rootProject.file("key.properties").exists() ||
                System.getenv("ANDROID_KEYSTORE_PATH") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
