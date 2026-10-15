# shopify-catalogue-fetcher

Nightly GitHub Actions job that pulls the public Shopify catalogues (`/products.json`, `/meta.json`,
per-product barcodes) of 37x Ltd's approved affiliate merchants and hands them to the
`shopify-catalogue-37x` Cloudflare Worker, which normalises them and stores them in R2.

Fetching runs here because Shopify throttles and soft-blocks Cloudflare Worker egress.
One request per second across all stores; backs off on 429 / Retry-After.

Secrets/vars: `INGEST_KEY` (secret, shared with the Worker), `WORKER_URL` (variable).
No credentials or data are stored in this repository.
