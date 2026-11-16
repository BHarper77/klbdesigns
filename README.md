# k.l.b designs

Portfolio site for artist Kirsty Baird. Astro + Tailwind, content from Contentful, hosted on S3 + CloudFront (Terraform in `deploy/`).

## Develop

```sh
npm ci
npm start          # dev server
npm run build      # astro check + build to dist/
```

Needs `CONTENTFUL_SPACE_ID` and `CONTENTFUL_ACCESS_TOKEN` in `.env`.

## Deploy

Merge to `main` -> GitHub Action -> build + Terraform apply. Never apply locally.

## Stall QR

`/m` is a CloudFront short link that redirects to `/?utm_source=stall&...` (shows the stall popup). See `functions/cloudfront.js`.

Regenerate the QR code (`public/stall-qr.svg`):

```sh
npm run generate:stall-qr
```
