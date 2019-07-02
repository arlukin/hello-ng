package se.cybercow.hellovertx

import io.vertx.core.AbstractVerticle
import io.vertx.core.Vertx
import io.vertx.ext.web.Router
import java.util.concurrent.CountDownLatch

class HelloNGServer : AbstractVerticle() {

    @Throws(Exception::class)
    override fun start() {
        val router = Router.router(vertx)

        router.route().handler { routingContext ->
            routingContext
                .response()
                .putHeader("content-type", "text/html")
                .end("Hello Engine!")
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