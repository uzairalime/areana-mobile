import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("development") {
            dimension = "flavor-type"
            applicationId = "com.example.arana360.dev"
            resValue(type = "string", name = "app_name", value = "Pitchside Dev")
        }
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.example.arana360"
            resValue(type = "string", name = "app_name", value = "Pitchside")
        }
    }

    buildFeatures.resValues = true
}