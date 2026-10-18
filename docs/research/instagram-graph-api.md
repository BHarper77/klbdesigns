# Instagram Graph API publishing — research (#31)

Researched 2026-10-18 against official Meta docs.

## Account requirements
- Must be an Instagram **professional** account (Business or Creator). Personal accounts can't publish via the API.
- There are two API setups:
  - **Instagram API with Instagram Login** (`graph.instagram.com`): **no FB Page needed**. Scopes: `instagram_business_basic` and `instagram_business_content_publish`. This is the simplest setup for us.
  - **Instagram API with Facebook Login** (`graph.facebook.com`): IG account must be linked to a FB Page, and the user needs MANAGE/CREATE_CONTENT task access on that Page. Scopes: `instagram_basic`, `instagram_content_publish`, `pages_read_engagement`. Only this setup gives resumable video upload and branded content.
- If the Page requires Page Publishing Authorization (PPA), publishing is blocked until PPA is done. This only applies to the FB Login setup.

**Owner must verify:** the KLB IG account is Business or Creator (switch it in IG settings if not). For the FB Login route, also check the FB Page link and PPA status. They also need a Meta developer account, and the IG account must be added as an app role (Instagram tester) on the app.

## App review
- **Standard Access** (the default) covers accounts owned or managed by people with a role on the app. **No App Review or Business Verification is needed** for a single-owner app.
- Advanced Access (App Review + Business Verification) is only needed to serve third-party accounts.

## Publishing flow
1. `POST /{IG_ID}/media` with `image_url` or `video_url` (plus `media_type`, caption, etc.). This returns a **container ID**. The media must be at a **public URL** when you call it, so CloudFront or Contentful asset URLs should work.
2. Video: poll `GET /{container}?fields=status_code` (once a minute, for at most 5 minutes) until `FINISHED`.
3. `POST /{IG_ID}/media_publish?creation_id={container}` returns the media ID.
- Containers **expire after 24h** if not published (status `EXPIRED`).

## Drafts / review step
- The API has no drafts and no IG-side approval queue. Our approval queue has to live on our side.
- You could create the container at approval time, or create it early and publish on approval. Containers expire after 24h, so the safest option is to create the container and publish it right away when the post is approved.

## Media specs
- **Image (feed):** JPEG only (no PNG/WebP, so we have to convert), 8 MB max, aspect ratio **4:5 to 1.91:1**, width 320–1440 px (scaled otherwise), sRGB.
- **Carousel:** up to **10** images/videos, which count as one post. **All items are cropped to the first item's aspect ratio** (default 1:1). Captions go on the parent container only. Reels can't be carousel items.
- **Reels** (`media_type=REELS`): MOV/MP4, H.264/HEVC, 23–60 fps, max width 1920 px, aspect ratio 0.01:1–10:1 (9:16 recommended), 3 s–15 min, 300 MB max, AAC audio. Feed video is published as Reels.
- **Stories** (`media_type=STORIES`) are also supported.
- Not supported: shopping tags and filters.

## Rate limits
- **100 API-published posts per rolling 24h per account**, enforced at `media_publish`. Check usage with `GET /{IG_ID}/content_publishing_limit`. The docs also mention 50 in one place, but either figure is far above our volume.
- Other calls fall under Business Use Case rate limits (per app+user, rolling 24h).

## Tokens
- Short-lived token: 1h. Exchange it for a **long-lived token (60 days)**.
- Refresh with `GET graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=…`. The token must be at least 24h old and not yet expired. Each refresh gives another 60 days.
- **We need a scheduled refresh job** (for example a weekly cron Lambda that stores the token in SSM or Secrets Manager). If the token expires, someone has to log in through OAuth again by hand.

## Setup tasks / blockers
1. Owner confirms the IG account is Business/Creator.
2. Create a Meta developer app with the Instagram product (Instagram Login), and add the IG account as a tester.
3. Run the OAuth flow once to get the long-lived token, then store it in SSM or Secrets Manager.
4. Build the token refresh cron.
5. Add an image pipeline that converts to JPEG and fits the 4:5–1.91:1 range, keeping one aspect ratio per carousel.

## Sources
- https://developers.facebook.com/docs/instagram-platform/content-publishing
- https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media
- https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login
- https://developers.facebook.com/docs/instagram-platform/overview
- https://developers.facebook.com/docs/instagram-platform/reference/refresh_access_token
