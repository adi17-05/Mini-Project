// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Flutter custom build directory setup (if required)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(name)
    layout.buildDirectory.value(newSubprojectBuildDir)
}

// Force project app to be evaluated first
subprojects {
    evaluationDependsOn(":app")
}

// Clean build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
