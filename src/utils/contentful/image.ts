type ImageOpts = {
  w: number;
  /** original asset width; never request larger */
  max?: number;
  q?: number;
  fm?: "webp" | "jpg" | "png";
};

/** Contentful Images API url. `url` is protocol-relative asset url. */
export function contentfulImage(
  url: string,
  { w, max, q = 75, fm = "webp" }: ImageOpts,
): string {
  const width = max ? Math.min(w, max) : w;
  const base = url.startsWith("//") ? `https:${url}` : url;
  return `${base}?w=${width}&fm=${fm}&q=${q}`;
}

/** srcset string; widths above the original are dropped (original width used if none fit) */
export function contentfulSrcset(
  url: string,
  widths: number[],
  max: number,
  q = 75,
): string {
  const usable = widths.filter((w) => w <= max);
  const list = usable.length ? usable : [max];
  return list
    .map((w) => `${contentfulImage(url, { w, q })} ${w}w`)
    .join(", ");
}
