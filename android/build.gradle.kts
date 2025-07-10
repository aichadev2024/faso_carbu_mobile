import org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔧 Configurer Kotlin pour utiliser Java 21
plugins.withId("org.jetbrains.kotlin.android") {
    extensions.configure<KotlinJvmProjectExtension>("kotlin") {
        jvmToolchain(21) // 🔥 C’est ça qui corrige le problème
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
