allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://edgedl.me.gvt1.com/android/maven2") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            buildToolsVersion = "36.0.0"
        }
    }
    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.gradle.AppExtension> {
            buildToolsVersion = "36.0.0"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
