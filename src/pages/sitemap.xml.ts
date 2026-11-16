import type { APIRoute } from "astro";
import { getTags } from "../utils/contentful/api";

const SITE = "https://klbdesigns.art";

export const GET: APIRoute = async () => {
  const tags = await getTags();
  const paths = [
    "/",
    "/about",
    "/contact",
    "/privacy",
    ...tags.map((t) => `/${t.id}`),
  ];
  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${paths.map((p) => `  <url><loc>${SITE}${p}</loc></url>`).join("\n")}
</urlset>
`;
  return new Response(body, {
    headers: { "Content-Type": "application/xml" },
  });
};
