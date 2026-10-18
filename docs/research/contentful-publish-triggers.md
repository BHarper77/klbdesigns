# Contentful publish triggers & content model

Research for #33 (map #10: sync Contentful media to Instagram/Etsy).

## Current repo state
- Read-only CDA client: `src/utils/contentful/api.ts`, `consts.ts` (`cdn.contentful.com`, env `master`, `CONTENTFUL_SPACE_ID`/`CONTENTFUL_ACCESS_TOKEN`).
- Entries queried by **tag**, not content type (`metadata.tags.sys.id[all]=...` in `src/components/Gallery.astro`, `src/components/StallPopup.astro`). Tags = collections; `featured` tag filtered out.
- Entry fields (`src/utils/contentful/types.ts` `WebsiteContentModel`): `media` (Asset link), `alt`, `title?`, `medium?`, `dimensions?` (string), `year?`, `instagramUrl?`, `etsyUrl?`. Content type id not referenced in code; check in web app.
- Asset fields used: `file.url`, `file.details.size`, `file.details.image.{width,height}`, `fileName`, `contentType`.
- No server/compute: static Astro on S3 + CloudFront (`deploy/s3.tf`, `deploy/cf.tf`, `deploy/r53.tf`). No CONTEXT.md found in repo.

## Webhooks
- Topics `Entry.publish`, `Entry.unpublish`, `Asset.publish`, etc. (`Type.Action`, wildcards ok). Configure in Settings > Webhooks or CMA.
- **Filters** only on sys props: `sys.environment.sys.id`, `sys.contentType.sys.id` (Entry events only), `sys.id`, `sys.createdBy`/`updatedBy`/`deletedBy`. One operator per filter: `equals`/`in`/`regexp`, `not` wraps; all filters ANDed (verified, /webhooks/filters). **Cannot filter on field values** (e.g. `share=true`) -> receiver must check flag itself.
- **Payload**: default = full entity in CMA format (`Content-Type: application/vnd.contentful.management.v1+json`, verified; locale keying + unresolved links inferred from CMA format, not stated on configure page) (fields locale-keyed: `fields.title["en-US"]`); asset links unresolved (only `sys.id`), receiver must fetch asset via CDA/CMA. Headers (verified): `X-Contentful-Topic` = `ContentManagement.Entry.publish`, `X-Contentful-Webhook-Name`, plus context headers for scheduled/bulk actions. (`X-Contentful-CRN` unverified.) Optional payload transformation (JSON template, `{ /payload/fields/... }` pointers) + custom headers.
- **Retries** (verified): only on 429/5xx, 3 attempts total ~30s apart (~1 min), then marked failed. 30s response timeout; **timeouts not retried**. Duplicates possible -> dedupe on `X-Contentful-Idempotency-Key` (SHA256 of event). -> ack fast (enqueue, 2xx).
- **Security**: request verification via signing secret (HMAC-SHA256; headers `x-contentful-signature`, `x-contentful-signed-headers`, `x-contentful-timestamp`); verified: HMAC-SHA256 hex over method+path+signed headers+body; `@contentful/node-apps-toolkit` `verifyRequest(secret, canonicalRequest, ttl)`, default TTL 30s. Also supports basic auth / secret custom header.
- Every publish fires (incl. re-publish of edits) -> dedupe/"already shared" state needed.

## Modelling "share" + per-platform fields
Options:
1. Fields on existing gallery type: `shareInstagram` (bool), `shareEtsy` (bool), `instagramCaption` (long text), `hashtags` (list), `etsyTitle`, `etsyDescription`, `etsyPrice`, `etsyQuantity`, `etsyTaxonomyId`. Simple; mixes web + social concerns.
2. Separate `socialPost` content type referencing gallery entry/assets (per-platform caption, status). Cleaner, allows multiple posts per artwork, webhook filter on `sys.contentType.sys.id=socialPost`.
3. Tag (`share-instagram`) - visible in `metadata.tags` in payload, but tags in this space already mean collections; avoid.
- Write-back: after posting, receiver can set existing `instagramUrl`/`etsyUrl` via CMA (needs CMA token; publishing triggers another webhook -> guard loop).
- Note `dimensions` is free string; Etsy wants structured dims/price -> new fields needed.

## Asset metadata
- `file.details.size` (bytes), `file.contentType` (MIME), `fileName`, `image.width/height` (images only). (Asset fields per repo `types.ts`; video + Images API details unverified live, docs rate-limited.) Video: no duration/dimensions in asset details. Images API (`images.ctfassets.net`) resizes/crops/converts (`w`,`h`,`fit`,`fm=jpg|webp|png`,`q`) - useful for IG aspect (4:5..1.91:1) and JPEG requirement. Videos served from `videos.ctfassets.net`, no transcoding.

## Compute for receiver (none today)
- Lambda + **Function URL** (cheapest, no API GW; do signature check in code) or API Gateway HTTP API (throttling/WAF). Lambda verifies sig -> writes to SQS/DynamoDB "pending approval" -> 200.
- Approval UI/step + poster Lambda (IG Graph API, Etsy Open API v3) separate. Secrets in SSM/Secrets Manager; add to Terraform in `deploy/`.

## Other Contentful features
- **Scheduled actions/Releases** (unverified): schedule publish; scheduled publish still fires `Entry.publish` webhook -> works unchanged.
- **Workflows** = Premium plan only (verified, help/workflows-overview); Tasks app on Free: could host approval inside Contentful instead of custom queue.
- **App Framework**: custom app (sidebar "Share" button, App Events w/ signed delivery, App Actions). Overkill for v1; plain webhook enough.
- Alternatives: Contentful->GitHub Action (repository_dispatch) avoids AWS infra but no approval storage.

## Sources
- https://www.contentful.com/developers/docs/webhooks/filters/
- https://www.contentful.com/help/workflows-overview/
- https://www.contentful.com/developers/docs/webhooks/overview/
- https://www.contentful.com/developers/docs/webhooks/configure-webhook/ (filters, transformation)
- https://www.contentful.com/developers/docs/webhooks/request-verification/
- https://www.contentful.com/developers/docs/references/content-management-api/#/reference/webhooks
- https://www.contentful.com/developers/docs/references/images-api/
- https://www.contentful.com/developers/docs/extensibility/app-framework/app-events/
- https://www.contentful.com/help/launch/scheduled-publishing/
- https://docs.aws.amazon.com/lambda/latest/dg/urls-configuration.html
