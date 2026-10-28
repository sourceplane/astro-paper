# apps/web — the site

A blog on Sat Naing's Astro theme
([satnaing/astro-paper](https://github.com/satnaing/astro-paper), MIT) —
Astro 7 and Tailwind CSS 4 — built fully static and served as Cloudflare
Workers Static Assets:

- `/` (the featured and recent posts), `/about/`, `/archives/`, `/search/`
- the posts: `/posts/` (paginated: `/posts/2/` …), a page per post
  (`src/content/posts/**/*.md|mdx`) with its own Open Graph image
  (`/posts/<slug>/index.png`), `/tags/` and `/tags/<tag>/`
- `/rss.xml`, `/sitemap-index.xml`, `/robots.txt`, the site's Open Graph
  image `/og.png`, and the Pagefind search index under `/pagefind/`

The site's name — the header, every page's title, the Open Graph image and
the feed — is `src/site.ts`. Its description, author, timezone, features,
socials and share links are `astro-paper.config.ts`; the about page is
`src/content/pages/about.md`; colours and typography are `src/styles/`.

```bash
pnpm dev        # astro dev on http://localhost:4321 (search needs one build first)
pnpm test       # vitest over Astro's container API (src/test)
pnpm build      # astro build + pagefind → dist/ (and the index copied to public/ for dev)
pnpm preview    # wrangler dev over dist/ and the Worker
```

`wrangler.jsonc` is what deploys: the Worker (`worker/index.ts`) and `dist/`
as its assets. A request that matches a file is served from the assets; one
that does not reaches the Worker, which hands it back to the assets for the
site's 404 page. Pages are directories: `/about` redirects to `/about/`.

How it is deployed — per environment, on merge to `main` — is the
repository's README and `component.yaml` beside this file.
