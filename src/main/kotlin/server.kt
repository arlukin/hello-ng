package se.cybercow.hellovertx

import io.vertx.core.AbstractVerticle
import io.vertx.core.Vertx
import io.vertx.ext.web.Router
import java.util.concurrent.CountDownLatch
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.KotlinModule
import java.io.File
import jdk.nashorn.internal.runtime.ScriptingFunctions.readLine
import java.io.InputStreamReader
import java.io.BufferedReader
import java.io.IOException
import java.util.*


/**
 * Read generated-resources/main/version.config generated by Gradle.
 *
 * Will throw exception when file is not found. This should crash
 * the start of the program.
 */
data class GradleConfig(val version: String, val git_revision: String, val buildtime: String)

val topLevelClass = object : Any() {}.javaClass.enclosingClass

fun getGradleConfig(): GradleConfig {
    val p = Properties()
    p.load(topLevelClass.classLoader.getResourceAsStream("version.config"))
    return GradleConfig(p.getProperty("version"), p.getProperty("git_revision"), p.getProperty("buildtime"))
}


class HelloNGServer : AbstractVerticle() {
    val gradleConfig = getGradleConfig()

    @Throws(Exception::class)
    override fun start() {
        val router = Router.router(vertx)

        router.route().handler { routingContext ->
            routingContext
                .response()
                .putHeader("content-type", "text/html")
                .end(
                    """Hello Engine!<br> 
Version: ${gradleConfig.version}<br>
Revision: ${gradleConfig.git_revision}<br>
Build time: ${gradleConfig.buildtime}""".trimMargin()
                )
        }

        vertx.createHttpServer().requestHandler(router).listen(5000)
    }

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            val vertx = Vertx.vertx()
            vertx.deployVerticle(HelloNGServer())

            CountDownLatch(1).await()
        }
    }
}