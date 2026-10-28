# astro-paper — implementation status

| Milestone | State | Landed |
|---|---|---|
| AP0 — the spec | ✅ | the repository's first commit |
| AP1 — the blog on Workers | ✅ | AP-2 |
| AP2 — a baseline | planned | AP-3 |

## Departures from the upstream theme

Everything not listed here is the theme as it is upstream at `35cfa7f`.

| # | What | Why |
|---|---|---|
| 1 | The app lives in `apps/web` of a pnpm workspace; `Dockerfile`, `compose.yaml`, `.dockerignore`, `cz.yaml`, `CHANGELOG.md`, `.github/` (its CI, issue and PR templates) and the Lighthouse badge are not carried; its VS Code snippets are `.vscode/astro-paper.code-snippets` at the root, its `extensions.json` and `launch.json` are not | Other hosts' and the upstream project's own files; the workspace has one `.vscode` |
| 2 | `wrangler.jsonc` names the Worker `<repo>-web`, with `main: ./worker/index.ts`, the `ASSETS` binding over `dist/`, `html_handling: auto-trailing-slash` and `not_found_handling: 404-page` | The composition deploys a Worker with its assets; the trailing-slash rule is the theme's own host's |
| 3 | `apps/web/worker/index.ts` | The Worker in front of the assets |
| 4 | `src/site.ts` (`SITE_NAME`) is the site's name; `astro-paper.config.ts` reads it as `site.title` | One rename seam |
| 5 | `site.url` is `https://astro-paper.example.com/` (the domain placeholder); `astro.config.ts`'s `site` is `PUBLIC_SITE_URL` when a deploy sets it, else that; `src/config.ts` resolves `site.url` from `import.meta.env.SITE` | Upstream's own origin is not a product's; each deploy names its own, and the feed and the images follow the canonical links |
| 6 | The edit-post link is `https://github.com/sourceplane/astro-paper/edit/main/apps/web/` and the GitHub social link the same repository (both renamed with the site) | Upstream's point at the theme's repository, not the site's |
| 7 | The missing-OG-image error names `astro-paper.config.ts:` instead of the theme | The leftover sweep fails on the theme's name in a code file; the file is where the fix goes |
| 8 | `build` is `astro build && pagefind --site dist && cp -r dist/pagefind public/` — upstream's without `astro check`, which is the workspace's `typecheck` | The workspace's `typecheck` / `lint` / `test` / `build` contract |
| 9 | `typecheck` is `astro check` (`vitest.config.ts` excluded from it, as astrowind), `lint` is `eslint .` (the theme's config, `.wrangler` ignored); Prettier stays, as `format` / `format:check` | The workspace's contract |
| 10 | Tests: `src/test/site.test.ts`, `src/test/origin.test.ts`, `src/test/worker.test.ts` (vitest over Astro's container API); `vitest`, `wrangler` and `@types/node` are dev dependencies | The theme ships none |
| 11 | `astro` is held at `7.3.8` (upstream `^7.0.3`, which resolves 7.4) | Astro 7.4 refuses Node below 22.23.4; the lanes and Baseline CI run `node-version: 22`, which some GitHub runners resolve to 22.23.3 |
| 12 | `.astro/` and the dev copy of the search index (`public/pagefind`) are ignored by git, the blueprint and the leak gate | What `astro check` and the build generate is a build's, not the site's |
| 13 | `pnpm-workspace.yaml`'s `allowBuilds` is pnpm 10's `onlyBuiltDependencies` (esbuild, workerd, sharp) | The workspace's pnpm |
