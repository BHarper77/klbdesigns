import { queryTags } from "./api";

/** "Festive Christmas cards" entry */
const POPUP_ENTRY_ID = "6KtWfF3g69AlU5HW3NTACB";

export type PopupEntry = {
  alt: string;
  /** protocol-relative contentful asset url */
  url: string;
  width: number;
  height: number;
};

let cached: Promise<PopupEntry | undefined> | undefined;

async function load(): Promise<PopupEntry | undefined> {
  let res = await queryTags(`sys.id=${POPUP_ENTRY_ID}&include=1`);
  if (!res.items[0]) {
    res = await queryTags(`metadata.tags.sys.id[all]=featured&limit=1`);
  }
  const item = res.items[0];
  const asset = item
    ? res.includes?.Asset?.find((a) => a.sys.id === item.fields.media.sys.id)
    : undefined;
  if (!item || !asset) return undefined;
  return {
    alt: item.fields.alt,
    url: asset.fields.file.url,
    width: asset.fields.file.details.image.width,
    height: asset.fields.file.details.image.height,
  };
}

/** Fetched once per build, shared by the stall popup and og:image */
export function getPopupEntry() {
  return (cached ??= load());
}

/** 1200x630 JPEG for link previews */
export function ogImageUrl(entry: PopupEntry) {
  return `https:${entry.url}?w=1200&h=630&fit=fill&fm=jpg&q=80`;
}
