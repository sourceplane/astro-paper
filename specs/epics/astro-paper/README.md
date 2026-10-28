# astro-paper — Vercel's AstroPaper template on Cloudflare Workers

**AstroPaper builds fully static — its search index and Open Graph images
included — so the port is where it is served: `dist/` as Cloudflare Workers
Static Assets behind one small Worker, deployed by Orun to stage and prod on
every merge — and the baseline that makes a copy of it somebody else's blog
in one landing.**

| | |
|---|---|
| Status | In progress — AP1 on main: the site runs on Workers |
| Upstream | [satnaing/astro-paper](https://github.com/satnaing/astro-paper) (MIT), at `35cfa7f` (v6.1.0 and one fix, 2026-08-05) |
| Reference | [astro-boilerplate](https://github.com/sourceplane/astro-boilerplate) — the same scaffolding, tests and bootstrap; [astrowind](https://github.com/sourceplane/astrowind) — the same static build behind one Worker |
| Key | `AP` |

## Read in this order

1. [design.md](design.md) — the theme, how each Vercel piece maps to
   Cloudflare, the repository and the build, and the alternative rejected.
2. [implementation-plan.md](implementation-plan.md) — the milestones and
   what each one lands.
3. [risks-and-open-questions.md](risks-and-open-questions.md) — what is not
   proven, and what was accepted.
4. [IMPLEMENTATION-STATUS.md](IMPLEMENTATION-STATUS.md) — what shipped, and
   every departure from the upstream theme.

## Milestones

| Milestone | What it lands | Task |
|---|---|---|
| AP0 — the spec | the repository, its intent, CI, tooling and spec index; this doc set | AP-1 |
| AP1 — the blog on Workers | the theme in `apps/web`, built static with its search index and images, served as assets behind one Worker | AP-2 |
| AP2 — a baseline | the console card, the build document, the context pack and the baseline's tests | AP-3 |
