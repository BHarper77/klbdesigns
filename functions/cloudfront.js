var STALL_CAMPAIGN = 'xmas-market-2026';

var SHORT_PATHS = {
	'/m': '/?utm_source=stall&utm_medium=qr&utm_campaign=' + STALL_CAMPAIGN,
};

function handler(event) {
	var request = event.request;
	var uri = request.uri;

	console.log({ uri })

	if (SHORT_PATHS[uri]) {
		return {
			statusCode: 302,
			statusDescription: 'Found',
			headers: {
				location: { value: SHORT_PATHS[uri] },
			},
		};
	}

	// Check whether the URI is missing a file name.
	if (uri.endsWith('/')) {
	  request.uri += 'index.html';
	}
	// Check whether the URI is missing a file extension.
	else if (!uri.includes('.')) {
	  request.uri += '/index.html';
	}
  
	return request;
}