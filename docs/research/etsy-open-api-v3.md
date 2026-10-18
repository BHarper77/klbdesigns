# Etsy Open API v3: creating listings (research for #32 / map #10)

## App access
- Single-shop owner app qualifies as a **Seller App**. Any seller with an active shop in good standing and no existing active app can register one, and approval takes minutes with no manual review. The app can only access the registered shop. [docs](https://developers.etsy.com/documentation/)
- Personal App (deeper review) and Commercial Access (manual review) are not needed for this use case.
- API terms: https://www.etsy.com/legal/api

## Auth
- OAuth 2 auth code flow with PKCE (S256) is mandatory. Authorize at `https://www.etsy.com/oauth/connect` and exchange the code at `https://api.etsy.com/v3/public/oauth/token`. [auth](https://developers.etsy.com/documentation/essentials/authentication)
- Scopes: `listings_w` (create/edit), `listings_r`, `listings_d`.
- Access token lasts 1 h and refresh token 90 d. Use the `refresh_token` grant to get new tokens. If the refresh token expires, the owner has to consent again in a browser, so the sync must refresh at least every 90 d and store the rotated token (for example in SSM or Secrets Manager).
- Every request needs `x-api-key: <keystring>:<shared_secret>`.

## Required fields for createDraftListing
[listings tutorial](https://developers.etsy.com/documentation/tutorials/listings)
- `quantity`, `title`, `description`, `price`, `who_made`, `when_made`, `taxonomy_id`.
- Physical items also need `shipping_profile_id` and `readiness_state_id` (processing profile).
- Find `taxonomy_id` with `getSellerTaxonomyNodes`.
- Create the shipping profile once with `createShopShippingProfile`, or reuse an existing one.
- Create the readiness state with `createShopReadinessStateDefinition` (`ready_to_ship` or `made_to_order`).
- Contentful entries don't hold price, quantity, taxonomy or shipping. They must come from defaults or from the approval step.

## Draft state
- `createDraftListing` creates a listing in `draft` state.
- Activate it with `updateListing` and `state=active`. Activation needs at least one image.
- Activating a listing incurs Etsy's listing fee, so keeping drafts gives a natural human-approval gate in the Etsy UI.

## Images
- Upload with `POST /v3/application/shops/{shop_id}/listings/{listing_id}/images` (multipart). Send either `image` (binary) or `listing_image_id` (reuse an image already in the shop).
- `rank` sets the position (1 = primary). `overwrite=true` replaces the image at that rank. Remove images with `deleteListingImage`. [third-party ref](https://www.withone.ai/knowledge/etsy/conn_mod_def%3A%3AGMUoaK05n74%3A%3AeWdE1kp8QoCaH_-7nSwfhQ/md)
- Limits (from third-party sources; the official reference doesn't confirm them):
  - Max 10 images per listing.
  - JPG, PNG or GIF. Animated GIF and transparent PNG are not supported.
  - 2000 px on the shortest side is recommended.
  - [source](https://exportfeed.helpscoutdocs.com/article/67-image-requirements)
- Adding or replacing photos on an existing listing works the same way on active listings, so attaching media to existing listings is feasible.

## Video
- `uploadListingVideo` uploads one video per call.
- By default a listing has 1 video, and a new upload replaces the existing one.
- `is_multi_video=true` allows 2 videos. A third upload, or a duplicate, returns 409. The docs say this option is available 21 Sep to 21 Oct 2026, so its status after that is unclear. [tutorial](https://developers.etsy.com/documentation/tutorials/listings)

## Rate limits
- Rate limits are per API key and include a per-second limit (QPS) and a rolling 24 h limit (QPD). The docs example is 150 QPS and 100k QPD; check the actual values in the Developer Portal. [rate limits](https://developers.etsy.com/documentation/essentials/rate-limits)
- Response headers: `x-limit-per-second`, `x-remaining-this-second`, `x-limit-per-day`, `x-remaining-today`.
- A `429` response includes `retry-after`.
- These limits are not a concern at this volume.

## Decision input (draft vs attach)
- **Draft listing per synced entry:** this is simplest to make safe, because nothing goes live without activation. It needs default price, quantity, taxonomy and shipping, or editing in Etsy before publishing.
- **Attach to existing listing:** the entry needs a mapping to a `listing_id` (for example a Contentful field). Uploads go live immediately on active listings, and the 10-image cap means choosing a rank or overwrite strategy.
- Option: support both. If a `listing_id` is mapped, attach; otherwise create a draft.

## Setup tasks / blockers
1. Register a Seller App at developers.etsy.com with the shop owner account, then store the keystring and shared secret.
2. Do a one-time PKCE consent (local script) to get the first refresh token, then store it with rotation.
3. Create or choose a shipping profile and a readiness state, and pick default taxonomy_id, who_made (`i_did`) and when_made.
4. Decide the price and quantity source for drafts.
