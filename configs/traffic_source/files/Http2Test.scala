
import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._

class Http2Test extends Simulation {

	val target = System.getProperty("target")

	val httpProtocol = http
		.baseUrl(target)
		.inferHtmlResources()
		.acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
		.acceptEncodingHeader("gzip, deflate")
		.acceptLanguageHeader("en-US,en;q=0.5")
		.doNotTrackHeader("1")
		.userAgentHeader("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:63.0) Gecko/20100101 Firefox/63.0")

	val headers_0 = Map(
		"Pragma" -> "no-cache",
		"Upgrade-Insecure-Requests" -> "1")

	val headers_1 = Map(
		"Accept" -> "*/*",
		"Pragma" -> "no-cache")

	val headers_2 = Map("Pragma" -> "no-cache")

    val uri2 = "https://fonts.googleapis.com/css"

	val scn = scenario("Http2Test")
		.exec(http("request_0")
			.get("/")
			.headers(headers_0)
			.resources(
			    http("request_1")
			        .get("")
			        .headers(headers_1)
		    )
		)

	setUp(
		scn.inject(
			constantUsersPerSec(30) during (300 seconds)
		).protocols(httpProtocol)
	)
}