import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Agrega el plugin de Google Services con la versión especificada
    id("com.google.gms.google-services") version "4.3.15"  // Especifica la versión aquí
}

val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    namespace = "com.codestar.vlsm_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.codestar.vlsm_app"
        minSdkVersion(23)  // Usar paréntesis para la función
        targetSdkVersion(34)  // Usar paréntesis para la función
        versionCode = 6  
        versionName = "1.0.1.1"  
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

repositories {
    google()  // Asegúrate de que esté incluido el repositorio de Google
    mavenCentral()
}

dependencies {
    // SDK de Firebase (Analytics)
    implementation("com.google.firebase:firebase-analytics:21.0.0")

    // Agregar SDKs adicionales de Firebase según sea necesario
    // Ejemplo: Firebase Firestore
    // implementation 'com.google.firebase:firebase-firestore:24.0.0'

    // Firebase Auth, si lo necesitas
    // implementation 'com.google.firebase:firebase-auth:21.0.0'
    
    implementation("com.google.android.gms:play-services-ads:24.2.0")

}

buildscript {
    repositories {
        google()  // Asegúrate de tener esta línea
        mavenCentral()
    }
    dependencies {
        // Asegúrate de usar la última versión disponible del plugin
        classpath("com.google.gms:google-services:4.3.15")  // Usa la versión más reciente
    }
}
