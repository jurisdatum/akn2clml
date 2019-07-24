package com.jurisdatum.tna.akn2clml;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;

public class Lambda implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

	private final LDAPP transform;

	public Lambda() throws IOException {
		transform = new LDAPP();
	}
	
	@Override
	public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
		String akn = request.getBody();
		if (akn == null) {
			return new APIGatewayProxyResponseEvent()
				.withStatusCode(400)
				.withHeaders(Collections.singletonMap("Content-Type", "text/plain"))
				.withBody("body is empty");
		}
		Map<String, String> params = request.getQueryStringParameters();
		String isbn = params == null ? null : params.get("isbn");
		String clml;
		try {
			clml = transform.transform(akn, isbn);
		} catch (Exception e) {
			return new APIGatewayProxyResponseEvent()
				.withStatusCode(500)
				.withHeaders(Collections.singletonMap("Content-Type", "text/plain"))
				.withBody(e.getLocalizedMessage());
		}
		return new APIGatewayProxyResponseEvent()
			.withStatusCode(200)
			.withHeaders(Collections.singletonMap("Content-Type", "application/xml"))
			.withBody(clml);
	}

}
