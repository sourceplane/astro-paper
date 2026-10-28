# astro-paper — decisions

The choices that shape this repository, one line each, with where the full
reasoning lives. Superseded decisions stay listed, marked, so the history
reads in order.

| # | Decision | Why | Source |
|---|---|---|---|
| 1 | The site builds fully static (`output: 'static'`, no adapter) and deploys as Workers Static Assets | AstroPaper is a static theme (its demo is Cloudflare Pages, its Dockerfile nginx); an adapter would move prerendering into workerd for nothing | `specs/epics/astro-paper/design.md` |
| 2 | One small Worker (`apps/web/worker/index.ts`) in front of the assets | The `cloudflare-workers-assets-turbo` composition deploys a Worker with its assets; this one hands unmatched requests back to the assets (the 404 page) and is where a redirect or an API route goes later | risk AP-B |
| 3 | Pagefind and the Open Graph images stay build-time | `pagefind --site dist` indexes the built pages into `dist/pagefind`; satori and sharp render `/og.png` and each post's `index.png` in Node during `astro build`; the Worker needs neither | `apps/web/package.json` (`build`) |
| 4 | Astro held at 7.3.8, the template's own dependency set otherwise | Astro 7.4 refuses any Node below 22.23.4, and the Node 22 some GitHub runners carry is 22.23.3 | IMPLEMENTATION-STATUS (departures) |
| 5 | The tests live in the app (`apps/web/src/test`), not a `tests/web` package | Astro components render only under Astro's own Vite config (the container API) | risk AP-D |
| 6 | One committed `wrangler.jsonc` is what deploys | There is no adapter to generate a second config; the lane checks the config exists before the build | `apps/web/component.yaml` |
| 7 | The site's name is one seam, `SITE_NAME` in `apps/web/src/site.ts`, read as `site.title` by `astro-paper.config.ts` | The rename rewrites one literal; the theme's config no longer spells the name | IMPLEMENTATION-STATUS (departures) |
| 8 | The theme's credit is masked from the rename: its repository, its config API (`astro-paper.config.ts`, `defineAstroPaperConfig` and its types), the home page's sentence naming it, and its name in its own posts and pages | This baseline's slug is the theme's name; renaming them would break the config import and leave the theme's documentation posts describing files the site does not have. Everything else is swept as before | `tooling/rebrand/rebrand.mjs` (UPSTREAM_CREDIT, THEME_WRITING), risk AP-G |
| 9 | `html_handling: auto-trailing-slash` | The theme writes directory pages and links them with a trailing slash (`/posts/<slug>/`), as its Cloudflare Pages demo serves them | `apps/web/wrangler.jsonc` |
| 10 | Each deploy builds for its own origin: `PUBLIC_SITE_URL` = the environment's `SITE_URL`, else its workers.dev URL; `astro-paper.config.ts`'s `site.url` (the domain placeholder) is a local build's | Canonical and Open Graph links, the sitemap, robots.txt and the RSS feed need an origin at build time, and each environment builds anyway (portfolio-starter-kit's shape) | risk AP-C |
| 11 | The edit-post link and the GitHub social link point at the site's own repository | They are the site's, and the rename follows the source link to a site's own repository | `apps/web/astro-paper.config.ts` |
| 12 | No custom-domain phase: a domain is the owner's step, and `SITE_URL` has the record probe it | The brokered `workers-deploy` token has no zone scope | README, "Custom domain" |
| 13 | One landing (`01-product`) then the record (`03-docs`), each checked in the build box | A landing has a fixed cost; the convergence on main builds, deploys and smoke-tests the site for real | `docs/phases/README.md` |
| 14 | `ci.yml` plans nothing while `intent.yaml` names `ws_CHANGE_ME`; no Checks workflow | A bootstrap cannot set a repository variable; a push to main must start `ci.yml` alone | `.github/workflows/ci.yml` |
| 15 | stack-tectonic 0.19.0, not 0.20.0 | The job installs in its own tree; 0.20.0's lane-shared install broke the Next.js siblings live and would save nothing here | risk AP-F |
| 16 | orun is pinned only where it runs (the `orun-action` `version:` in each workflow); no kiox | A pin nothing runs drifts | `.github/workflows/` |
| 17 | Component docs are generated from the manifests and checked in CI | A hand-written copy of the component's facts drifts silently | `tooling/catalog/gen-component-docs.py` |
| 18 | `subdomain` is read from the Cloudflare connection, never asked; the console asks for no domain | Both belong to the account or the owner, not to the build | `blueprint.yaml` |
