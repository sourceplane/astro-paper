# astro-paper — design

## The theme

[AstroPaper](https://github.com/satnaing/astro-paper) is a minimal,
responsive, accessible and SEO-friendly Astro 7 + Tailwind CSS 4 blog theme:
a home page with featured and recent posts, Markdown and MDX posts in
`src/content/posts/` (in folders, with drafts and scheduled posts), a
paginated posts index, tag pages, archives, an about page from
`src/content/pages/about.md`, full-text search with Pagefind, a dynamic Open
Graph image for the site (`/og.png`) and for every post without one of its
own (`/posts/<slug>/index.png`) rendered with satori and sharp, light and
dark mode, callouts, an image lightbox, an RSS feed and a sitemap. Its user
configuration is one file, `astro-paper.config.ts`, typed by
`defineAstroPaperConfig`; `src/config.ts` resolves it with defaults.

It is `output: 'static'`: every route is a file at build time, and the build
runs Pagefind over the output (`astro check && astro build && pagefind --site
dist`). Its demo is on Cloudflare Pages, and it ships a Dockerfile for nginx.

## How it maps to Cloudflare

| Vercel | Here | Why |
|---|---|---|
| Static output on Vercel's CDN | `dist/` as Workers Static Assets, uploaded with `<repo>-web-<env>` | The theme is static; the assets are the site |
| — | One Worker, `apps/web/worker/index.ts`, hands unmatched requests to the assets | The `cloudflare-workers-assets-turbo` composition deploys a Worker with its assets; a request no file matches reaches it and gets the site's 404 |
| The build's Pagefind step | Unchanged: `pagefind --site dist` writes `dist/pagefind`, served as assets | Search is client-side over a static index |
| Open Graph images rendered at build | Unchanged: satori and sharp in Node during `astro build` | Nothing is rendered at request time; the Worker needs no image code |
| Directory pages linked with a trailing slash | `assets.html_handling: auto-trailing-slash` | The theme's own host (Cloudflare Pages) serves `/posts/<slug>/` and redirects `/posts/<slug>` to it |
| The host's 404 | `not_found_handling: 404-page` → `dist/404.html` with a 404 | The theme's own 404 page |
| `site.url: https://astro-paper.pages.dev/` | `PUBLIC_SITE_URL` per deploy: the environment's `SITE_URL`, else its workers.dev URL; `site.url` (`<repo>.example.com`) for a local build | Canonical and Open Graph links, the sitemap, robots.txt and the RSS feed need an origin at build |

## The repository

The same as astro-boilerplate's, with astrowind's static build: `apps/web` is
the only component (type `cloudflare-workers-assets-turbo`, lane `isolated`,
deployed on stage and prod on a push to `main`, verified on dev and on pull
requests), its tests live in the app because Astro components render only
under Astro's Vite config, and there is no infrastructure: no database, no
bucket, no runtime secret. The site's name is one seam, `SITE_NAME` in
`src/site.ts`, which `astro-paper.config.ts` reads as `site.title` — the
header, every page's title, the Open Graph site name and images, the feed.
`astro.config.ts` takes `PUBLIC_SITE_URL` over the config's `site.url`, and
`src/config.ts` resolves the URL from Astro's own `site`
(`import.meta.env.SITE`), so the feed and the images use the same origin as
the canonical links. The edit-post link and the GitHub social link point at
the site's own repository.

This baseline's slug is the theme's own name, and the theme spells it in its
code and its writing: its config file is `astro-paper.config.ts` (imported by
that name), its helper `defineAstroPaperConfig`, its home page introduces it
by name, and its posts — its documentation and its release notes — name it
throughout, its release posts at URLs like `/posts/astro-paper-v6/`. Renaming
the config file or the helper would leave those posts describing a file and
a function the site does not have, so the rename engine masks them as the
theme's credit, with the theme's repository and the home page's sentence.
In the posts and pages under `src/content` the theme's name in either
spelling is the theme's. Everywhere else — every code file, every manifest,
every doc a site carries — the slug, its Pascal form and its env prefix
still fail the leftover sweep.

## The build

`repo-blueprint.yaml` is astro-boilerplate's: one landing (`01-product`)
places, brands and lands the whole tree, one convergence builds and deploys
stage and prod side by side, and `03-docs` records what went live. The
smoke checks the home page is the theme's, that `/posts/` lists its posts,
that the search index is served, and that an unknown path is a 404.

## Out of scope

- Comments: the theme documents Giscus in a post; it is not wired, as
  upstream.
- Google Search Console: `site.googleVerification` (or
  `PUBLIC_GOOGLE_SITE_VERIFICATION` at build) is empty, as upstream.

## The alternative rejected

**Astro's Cloudflare adapter**, as astro-boilerplate uses. It would move the
build's prerendering into workerd through the Cloudflare Vite plugin, emit a
server entry nothing calls, generate a second wrangler config the e2e tier
would have to hold to the committed one, and move the Open Graph images'
sharp out of Node — all for a site with no on-demand route. A static build
with a Worker in front of it is what the theme is.
