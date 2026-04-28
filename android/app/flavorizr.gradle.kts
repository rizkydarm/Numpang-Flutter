import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.rizkyeky.numpangdev"
            resValue(type = "string", name = "app_name", value = "Numpang Dev")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.rizkyeky.numpang"
            resValue(type = "string", name = "app_name", value = "Numpang")
        }
    }
}