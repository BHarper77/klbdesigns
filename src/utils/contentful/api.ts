import { accessToken, baseUrl } from "./consts"
import type { TagsQueryResponse, TagsResponse } from "./types"

export async function getTags() {
	const response = await fetch(`${baseUrl}/tags?access_token=${accessToken}`, {
		method: "GET",
		redirect: "follow",
	})

	if (!response.ok) {
		throw new Error(`Error requesting tags. Status code: ${response.status}`)
	}

	const tags = (await response.json()) as TagsResponse
	const parsedTags = tags.items
		.map(item => ({
			name: item.name,
			tag: toCamelCase(item.name)
		}))
		.filter(item => item.name !== "featured")

	return parsedTags
}

/** Convert tags to camelCase for API request */
function toCamelCase(string: string) {
    return string
        .toLowerCase()
        .replace(/[^a-zA-Z0-9]+(.)/g, (_, chr) => chr.toUpperCase())
}

export async function queryTags(query: string) {
	const url = `${baseUrl}/entries?
		access_token=${accessToken}&
		${query}`

	const response = await fetch(url, {
		method: "GET",
		redirect: "follow",
	})

	if (!response.ok) {
		throw new Error(`Error querying tags. Status code: ${response.status}`)
	}

	const tags = (await response.json()) as TagsQueryResponse
	return tags
}