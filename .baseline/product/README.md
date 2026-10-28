# astro-paper

A blog on Sat Naing's Astro theme
([satnaing/astro-paper](https://github.com/satnaing/astro-paper)) — minimal,
responsive, accessible and SEO-friendly: posts in Markdown and MDX with tags,
archives and pagination, full-text search with Pagefind, a dynamic Open
Graph image for the site and for every post, light and dark mode, an RSS
feed and a sitemap — built fully static and served from **Cloudflare Workers
+ Static Assets**.

## Live deployment

<!-- 03-docs:begin -->
Not recorded yet. The bootstrap's last phase writes the live URLs, the
workspace and the secrets the site uses into
[ai/context/deployment.md](ai/context/deployment.md); how the site deploys
and how to operate it is in
[ai/context/operations.md](ai/context/operations.md).
<!-- 03-docs:end -->

## What is here

| Surface | Where |
|---|---|
| The site's name (the header, every page's title, the OG image, the feed) | `apps/web/src/site.ts` |
| The theme's configuration: description, author, timezone, posts per page, features (dark mode, dynamic OG images, archives, the edit link, search), socials, share links | `apps/web/astro-paper.config.ts` |
| Posts (`.md` / `.mdx`) and the about page | `apps/web/src/content/posts`, `apps/web/src/content/pages` |
| Pages (a file per route), layouts and components | `apps/web/src/pages`, `apps/web/src/layouts`, `apps/web/src/components` |
| Colours, typography | `apps/web/src/styles` |
| The Open Graph images (the site's and each post's) | `apps/web/src/pages/og.png.ts`, `apps/web/src/pages/posts/[...slug]/index.png.ts` |
| The Worker in front of the assets, its config and deploy contract | `apps/web/worker/index.ts`, `apps/web/wrangler.jsonc`, `apps/web/component.yaml` |
| Tests (the name seam, the origin, the Worker) | `apps/web/src/test` |

## Getting started

```bash
pnpm install
pnpm typecheck        # astro check
pnpm lint             # eslint
pnpm test             # vitest over Astro's container API
pnpm build            # astro build + pagefind → apps/web/dist (every page, image and the search index)
```

```bash
pnpm --filter @app/web dev        # http://localhost:4321 (search needs one build first)
pnpm --filter @app/web preview    # wrangler dev over the built site and its Worker
```

Make the site yours: its name in `apps/web/src/site.ts`; its description,
author, socials and features in `apps/web/astro-paper.config.ts`; its posts
in `apps/web/src/content/posts/` and its about page in
`apps/web/src/content/pages/about.md`. The posts it was born with are the
theme's own documentation — how to configure it, add posts, change its
colour schemes, its Open Graph images — kept until you replace them. A
binding the Worker needs (KV, R2, D1, a variable) goes in
`apps/web/wrangler.jsonc`.

The site is static: every page, image and the search index are files in
`dist/` at build time, and the Worker (`apps/web/worker/index.ts`) only
hands requests that match no file back to the assets, which answer with the
site's own 404 page. A redirect, a header or an API route the site needs
later goes in that Worker.

## How it deploys

Merges to `main` converge through [Orun](https://github.com/sourceplane/orun):
`.github/workflows/ci.yml` plans the changed components and runs each lane
against the workspace in `intent.yaml`. The site deploys to `stage`, then to
`prod` once stage has converged on the same commit; `dev` only verifies. The
Worker is `astro-paper-web-<env>` on your account's workers.dev
subdomain, and every deploy is smoke-tested over HTTP. A pull request runs
the same pipeline's verify lanes: the site built and dry-deployed for each
environment, with nothing deployed. They do not type-check, lint or run the
tests, so run `pnpm typecheck`, `pnpm lint` and `pnpm test` before you push.
(A push to `main` builds, deploys and smoke-tests.)

The pipeline holds one credential, GitHub's own `GITHUB_TOKEN`. The
Cloudflare token and account id are brokered per run from the workspace's
Cloudflare connection; nothing provider-shaped is stored in the repository
or in GitHub.

**Deploy by hand.** Orunbase's **Deploy** button on a component, or **Run
workflow** on the CI workflow in GitHub's Actions tab (on `main`), runs
`ci.yml` for the environment and components you pick, and each one deploys
exactly as a merge would deploy it. Leave the component blank to redeploy
every component in that environment, with nothing changed: after rotating a
secret, say. A component with nothing to run in that environment (a test
suite in `prod`) is left out with a notice.

## Custom domain

The site answers on workers.dev from its first deploy. To serve it on your
own domain:

1. Add the domain to the Cloudflare account the site deploys into, and attach
   it to the Worker (dashboard → Workers & Pages →
   `astro-paper-web-prod` → Settings → Domains & Routes → Add →
   Custom domain). Do the same for stage with a subdomain if you want one.
2. Record the environment's public origin in `intent.yaml`: the deploy
   builds the site's canonical and Open Graph links, sitemap, robots.txt and
   RSS feed for it (until then they name the workers.dev URL), and the
   deployment record probes it beside the workers.dev URL:

   ```yaml
   environments:
     prod:
       env:
         SITE_URL: https://astro-paper.example.com
   ```

   The site was born with the reserved placeholder
   `astro-paper.example.com` where its domain goes: that example,
   `BASE_DOMAIN` under each environment (dev, stage and prod) in
   `intent.yaml`, and `site.url` in `apps/web/astro-paper.config.ts` — the
   origin a local build uses. Replace it with your domain in the same
   change, and land it with a change under `apps/web` so the merge rebuilds
   the site.

## Credits

The theme is [satnaing/astro-paper](https://github.com/satnaing/astro-paper),
© Sat Naing, MIT-licensed (`apps/web/LICENSE`). Its home page, about page
and posts describe the theme and link to that repository; replace them with
your own content as you make the site yours.
