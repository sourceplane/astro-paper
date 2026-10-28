# astro-paper — where this repository stands

The entry page for anyone (or any agent) picking this repository up. It is
this repository's own state and does not ship to a site built from it; the
two pages that do are [operations.md](operations.md) and
[deployment.md](deployment.md).

## What it is

Vercel's AstroPaper template (satnaing/astro-paper) — a minimal, accessible
Astro blog theme: Markdown/MDX posts with tags, archives and pagination,
Pagefind search, an Open Graph image per post rendered at build time, light
and dark mode, RSS and a sitemap — built fully static and served as
Cloudflare Workers Static Assets behind one small Worker, packaged as an Orun
baseline: `orun new --blueprint repo-blueprint.yaml` builds a new site in its
own repository and takes it to live on stage and prod in one landing
(`01-product`), then records what went live (`03-docs`).

## Release

| | |
|---|---|
| Latest tag | `baseline-v1` — AP0 to AP2: the repository, the blog on Workers, and the baseline (blueprint, phases, tests) |
| Proven live | Not yet: proven offline in Baseline CI only (risk AP-A) |

## Where to read

| Question | Page |
|---|---|
| What shipped, and every departure from upstream | `specs/epics/astro-paper/IMPLEMENTATION-STATUS.md` |
| Why it is built this way | [decisions.md](decisions.md), then `specs/epics/astro-paper/design.md` |
| What could still go wrong | [open-risks.md](open-risks.md), then `specs/epics/astro-paper/risks-and-open-questions.md` |
| How to instantiate it | `BOOTSTRAP.md`, `docs/phases/` |
| What the component is | `apps/web/docs/` (generated; `python3 tooling/catalog/gen-component-docs.py`) |

## Next

1. Bootstrap one site from `baseline-v1` from the console and record its
   timings against the 4-minute estimate (closes AP-A); then the registry
   row goes public with the measured minutes.
