import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("development") {
            dimension = "flavor-type"
            applicationId = "com.zorixsolutions.arana.dev"
            resValue(type = "string", name = "app_name", value = "Sportivo Dev")
        }
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.zorixsolutions.arana"
            resValue(type = "string", name = "app_name", value = "Sportivo")
        }
    }

    buildFeatures.resValues = true
}