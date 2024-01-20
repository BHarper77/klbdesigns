const apiKey = ''

export async function handler(event) {
	const response = await fetch('https://api.resend.com/emails', {
		method: 'POST',
    	headers: {
      		'Content-Type': 'application/json',
      		'Authorization': `Bearer ${apiKey}`,
    	},
    	body: JSON.stringify({
      		from: 'contact@klbdesigns.art',
     		to: ["bradyharper11@googlemail.com"],
      		subject: 'hello world',
      		html: '<strong>it works!</strong>',
    	}),
  	})

  	if (response.ok) {
    	const data = await response.json()

    	return {
      		statusCode: response.status,
      		body: data,
    	}
  	}
	else {
		return {
			statusCode: response.status
		}
	}
}