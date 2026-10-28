# astro-paper

Vercel's [AstroPaper](https://github.com/satnaing/astro-paper) template — a
minimal, responsive, accessible and SEO-friendly Astro blog theme: posts in
Markdown and MDX with tags, archives and pagination, full-text search with
Pagefind, a dynamic Open Graph image for the site and for every post, light
and dark mode, an RSS feed and a sitemap — running on **Cloudflare Workers +
Static Assets**, and packaged as an **Orun baseline**: one command takes a
new blog from nothing to live on stage and prod, in its own repository,
under its own name.

AstroPaper builds fully static: `astro build` writes every page, post, tag
page, feed, sitemap and Open Graph image (satori and sharp, at build time) to
`dist/`, and Pagefind indexes the built pages into `dist/pagefind`. That
folder is uploaded as Workers Static Assets with one small Worker in front
for what matches no file; no adapter and no server code. The pages, the
posts, the search and the theme do not change; the site's name moves into
one module, and each deploy builds for its own origin. What the baseline
adds is everything needed to make a copy of it somebody else's — built the
way [cirrus-baseline](https://github.com/sourceplane/cirrus-baseline) is.
See [`specs/epics/astro-paper`](specs/epics/astro-paper/README.md) for the
design, the milestones and the as-built status.

## Instantiating a site

```bash
git clone --depth 1 --branch <baseline-tag> https://github.com/sourceplane/astro-paper
cd astro-paper
orun new --blueprint repo-blueprint.yaml --out ~/sites/acme-notes --run-hooks --resume \
  --set reponame=acme-notes --set productname="Acme Notes" \
  --set githuborg=acme-inc --set subdomain=<workers-dev-subdomain>
```

Or, once the platform's registry lists it, from the Orun console (Baselines →
`astro-paper` → Build). Two phases — `01-product` (the repository
created, then the whole site in one pull request, deployed to stage and prod
and smoke-tested) and `03-docs` (the live deployment recorded) — each landing
one pull request in the new repository. **[BOOTSTRAP.md](BOOTSTRAP.md)** is the
operator guide; [docs/phases/](docs/phases/README.md) has a page per phase.

The new repository receives the **site only** — the app and its tests, its
CI, its tooling, a README of its own and its operating contract — renamed
throughout to the site's name, repository and Cloudflare Worker. None of this
repository's machinery ships.

| What makes it a baseline | Where |
|---|---|
| The console card (inputs, secrets, programme) | `blueprint.yaml` |
| The build document (modules, phases, hooks) | `repo-blueprint.yaml` |
| This tree's identity, and the bootstrap's task contracts | `.baseline/` |
| The rename engine | `tooling/rebrand/rebrand.mjs` |
| The bootstrap's helpers (deferrals, redeploy marker, work-tree strip) | `tooling/bootstrap/` |
| The deployment-record renderer | `hooks/render-deployment-docs.sh` |
| The site's README and context pack | `.baseline/product/README.md`, `ai/context/` |
| The baseline's tests: contract, leak, offline bootstrap, end to end | `testing/`, `.github/workflows/baseline.yml` |
| Cutting a `baseline-vN` tag | `.github/workflows/tag.yml` |

### The theme's name is this repository's slug

AstroPaper's name is `astro-paper`, so the slug every rename starts from is
also the name the theme gives its own files, functions and documentation. The
rename engine renames neither: `satnaing/astro-paper`, the config file
`astro-paper.config.ts` (with `defineAstroPaperConfig` and its types), the
home page's sentence introducing the theme, and the theme's name in its own
posts and pages under `apps/web/src/content` are masked as the theme's
credit (`tooling/rebrand/rebrand.mjs`, `UPSTREAM_CREDIT` and
`THEME_WRITING`). Anything else that spells the slug, its Pascal form or its
env prefix still fails the leftover sweep.

## What is here (the site)

| Surface | Where |
|---|---|
| The site's name (the header, every page's title, the OG image, the feed) | `apps/web/src/site.ts` |
| The theme's configuration (description, author, features, socials, share links) | `apps/web/astro-paper.config.ts` |
| Posts and the about page | `apps/web/src/content/posts`, `apps/web/src/content/pages` |
| Pages, layouts, components, the OG image routes | `apps/web/src/pages`, `apps/web/src/layouts`, `apps/web/src/components` |
| The Worker in front of the assets, its config, deploy contract | `apps/web/worker/index.ts`, `apps/web/wrangler.jsonc`, `apps/web/component.yaml` |
| Tests (the name seam, the origin, the Worker) | `apps/web/src/test` |

## Getting started

```bash
pnpm install
pnpm typecheck        # astro check
pnpm lint             # eslint
pnpm test             # vitest over Astro's container API
pnpm build            # astro build + pagefind → apps/web/dist
```

```bash
pnpm --filter @app/web dev        # http://localhost:4321 (search needs one build first)
pnpm --filter @app/web preview    # wrangler dev over the built site and its Worker
```

## How it maps to Vercel

| Vercel | Here |
|---|---|
| Static output (`dist/`) on Vercel's CDN | Workers Static Assets: `dist/` uploaded with the Worker `<repo>-web-<env>` (`apps/web/wrangler.jsonc`) |
| The template's build (`astro check && astro build && pagefind --site dist`) | Unchanged but for `astro check`, which runs as the `typecheck` step: `astro build`, then Pagefind into `dist/pagefind`, then the index copied to `public/` for `astro dev` |
| Open Graph images rendered by satori + sharp at build time | Unchanged: `/og.png` and each post's `index.png` are files in `dist/` |
| Directory URLs (`/posts/<slug>/`), as the theme's own Cloudflare Pages demo serves them | `assets.html_handling: auto-trailing-slash` — `/about/` serves `about/index.html`, `/about` redirects to it |
| The host's 404 for an unknown path | the Worker hands it to the assets, which answer `dist/404.html` with a 404 (`not_found_handling: 404-page`) |
| `site.url: https://astro-paper.pages.dev/` | Each deploy builds for its own origin — the environment's `SITE_URL`, else its workers.dev URL — so canonical and Open Graph links, the sitemap, robots.txt and the RSS feed name the site where it is served; `astro-paper.config.ts`'s `site.url` is a local build's |
| Deploy on push | Orun deploys `<repo>-web-{stage,prod}` on merge to `main` (`apps/web/component.yaml`) |
| "Deploy with Vercel" (clone the template) | `orun new --blueprint repo-blueprint.yaml` — a new repository, branded, deployed |

## CI

| Workflow | What it runs | Ships to a site |
|---|---|---|
| `ci.yml` | the Orun pipeline, and the only workflow a site carries: `orun plan --changed`, then one job per lane. A pull request runs the verify lanes (the site built and dry-deployed per environment — they do not type-check, lint or run the tests; `baseline.yml`'s e2e tier runs those before each tag, and a site's README asks its developers to run them before a push), except the bootstrap's own landings (`orun/BASE-*`), which are checked in the box before they are pushed (`checks: local`) and whose PR runs `plan` alone; a merge deploys stage → prod. It plans nothing while `intent.yaml` names the placeholder workspace `ws_CHANGE_ME`, as this repository does. A manual run (Orunbase's Deploy button, or Run workflow on `main`) plans the environment and components it names under the push-to-main trigger, so they deploy as a merge deploys them | yes |
| `baseline.yml` | the baseline's own tiers: contract tests, the blueprint read by the pinned orun, the leak gate, the offline bootstrap, the site built, dry-deployed and served | no |
| `tag.yml` | cuts a `baseline-vN` tag (manual) | no |

## Credits

The site is [satnaing/astro-paper](https://github.com/satnaing/astro-paper)
by Sat Naing (MIT — `apps/web/LICENSE`), at `35cfa7f` (v6.1.0 and one fix).
