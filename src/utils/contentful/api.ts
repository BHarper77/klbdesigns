import { accessToken, baseUrl } from "./consts";
import type { TagsQueryResponse, TagsResponse } from "./types";

export type CollectionWithCount = {
  name: string;
  tag: string;
  itemCount: number;
};

export async function getTags(): Promise<CollectionWithCount[]> {
  const response = await fetch(`${baseUrl}/tags?access_token=${accessToken}`, {
    method: "GET",
    redirect: "follow",
  });

  if (!response.ok) {
    throw new Error(`Error requesting tags. Status code: ${response.status}`);
  }

  const tags = (await response.json()) as TagsResponse;
  const filteredTags = tags.items.filter((item) => item.name !== "featured");

  // Fetch item counts for each tag in parallel
  const tagsWithCounts = await Promise.all(
    filteredTags.map(async (item) => {
      const tagId = toCamelCase(item.name);
      const count = await getTagItemCount(tagId);
      return {
        name: item.name,
        tag: tagId,
        itemCount: count,
      };
    })
  );

  return tagsWithCounts;
}

/** Get the count of items for a specific tag */
async function getTagItemCount(tagId: string): Promise<number> {
  const url = `${baseUrl}/entries?access_token=${accessToken}&metadata.tags.sys.id[all]=${tagId}&limit=0`;

  const response = await fetch(url, {
    method: "GET",
    redirect: "follow",
  });

  if (!response.ok) {
    console.error(`Error getting count for tag ${tagId}: ${response.status}`);
    return 0;
  }

  const data = (await response.json()) as { total: number };
  return data.total;
}

/** Convert tags to `camelCase` for API request, and ensure first character is lower case */
function toCamelCase(string: string) {
  const camelCase = string
    .toLowerCase()
    .replace(/[^a-zA-Z0-9]+(.)/g, (_, chr) => chr.toUpperCase());

  return camelCase.charAt(0).toLowerCase() + camelCase.slice(1);
}

export async function queryTags(query: string) {
  const url = `${baseUrl}/entries?
		access_token=${accessToken}&
		${query}`;

  const response = await fetch(url, {
    method: "GET",
    redirect: "follow",
  });

  if (!response.ok) {
    throw new Error(`Error querying tags. Status code: ${response.status}`);
  }

  const tags = (await response.json()) as TagsQueryResponse;
  return tags;
}
