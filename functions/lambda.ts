import type { APIGatewayProxyEventV2 } from "aws-lambda"

export async function handler(event: APIGatewayProxyEventV2) {
	const { name, email, subject, message } = JSON.parse(event.body ?? "")

	const response = await fetch('https://api.resend.com/emails', {
		method: 'POST',
    	headers: {
      		'Content-Type': 'application/json',
      		'Authorization': `Bearer ${process.env.API_KEY}`,
    	},
    	body: JSON.stringify({
      		from: 'website@klbdesigns.art',
     		to: ["bradyharper11@googlemail.com"],
      		subject,
      		html: `<p>From:${name} - ${email}</p><p>${message}</p>`,
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