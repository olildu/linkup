allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    // No plugins defined here in the original, but you might have some in your actual file
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add your buildscript dependencies here, e.g.,
        // classpath("com.android.tools.build:gradle:...")
        // classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:...")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)
subprojects {
    // fix for verifyReleaseResources
    // ============
    afterEvaluate {
        val project = this // 'this' refers to the Project

        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            val androidExtension =
                project.extensions.getByName("android") as? com.android.build.gradle.LibraryExtension
                    ?: project.extensions.getByName("android") as? com.android.build.gradle.AppExtension

            androidExtension?.apply {
                compileSdkVersion(36)
                buildToolsVersion = "36.0.0"
            }
        }

        if (project.extensions.findByName("android") != null) {
            val androidExtension =
                project.extensions.getByName("android") as? com.android.build.gradle.LibraryExtension
                    ?: project.extensions.getByName("android") as? com.android.build.gradle.AppExtension

            androidExtension?.apply {
                if (namespace == null) {
                    namespace = project.group.toString()
                }
            }
        }
    }
    // ============
    buildDir = file("${rootProject.buildDir}/${project.name}")
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}