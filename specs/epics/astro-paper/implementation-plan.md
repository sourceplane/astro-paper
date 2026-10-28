# astro-paper — implementation plan

Three milestones, each one reviewed pull request (AP0 is the repository's
first commit), each green before it merges.

## AP0 — the spec (AP-1)

The repository is born: `intent.yaml` with the placeholder workspace
`ws_CHANGE_ME`, `ci.yml` (byte for byte turso-starter's, which plans nothing
until the workspace is set), the shared TypeScript and ESLint configuration,
the spec index, this doc set and the task contracts.

## AP1 — the blog on Workers (AP-2)

- The theme's `src/`, `public/`, `astro-paper.config.ts`, `astro.config.ts`,
  ESLint and Prettier configuration in `apps/web`, its dependencies in
  `apps/web/package.json`, its VS Code post snippets beside the workspace's
  settings.
- `worker/index.ts` and `wrangler.jsonc`: the Worker in front of `dist/`,
  directory URLs, the 404 page.
- The site's name in `src/site.ts`, read as `site.title`; the origin from
  `PUBLIC_SITE_URL` through Astro's `site`; the edit and GitHub links to the
  site's own repository.
- `component.yaml`: the deploy contract and its smoke.
- Tests (`src/test`): the name seam, the header, the origin, the Worker.
- The README's "How it maps to Vercel".

## AP2 — a baseline (AP-3)

astro-boilerplate's machinery, renamed: `blueprint.yaml`,
`repo-blueprint.yaml`, `.baseline/` (identity, product README, task
contracts), `tooling/rebrand` (with the theme's credit masked: its
repository, its config API, its home page's sentence, its own posts),
`tooling/bootstrap`, `hooks/render-deployment-docs.sh` (probing `/` and
`/posts/`), `docs/phases/`, the context pack, `testing/` (the leak and
placement gates on this tree's files; the e2e tier reading every route the
site promises) and `baseline.yml` / `tag.yml`.
