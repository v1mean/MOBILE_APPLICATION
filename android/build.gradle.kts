allprojects {
    repositories {
        google()
        mavenCentral()
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
}

// Some plugin modules (e.g. flutter_stripe's stripe_android) don't pin a
// Kotlin jvmTarget, so Gradle defaults them to the installed JDK's target
// (21), while the app module targets 17 — causing a Java/Kotlin mismatch.
// Force every module to 17 for consistency. Uses lazy configuration
// (plugins.withId / tasks.withType.configureEach) instead of afterEvaluate,
// since evaluationDependsOn(":app") above can already evaluate some
// subprojects before a plain subprojects { afterEvaluate {} } runs on them.
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
    // stripe_android's release lint classpath needs play-services-tapandpay,
    // a private Google artifact that can't be resolved from public repos.
    tasks.matching { it.name.startsWith("lintVital") }.configureEach {
        enabled = false
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
