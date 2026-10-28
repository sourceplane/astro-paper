# Epics

Orun-style work programs. Each epic is a folder carrying `epic.yaml` (the
declaration the platform reads: slug, key prefix, milestones with exit
criteria and task keys) beside its doc set. The pull request that adds the
folder is the adoption; the merge creates the epic in the workspace.

| Epic | Cluster | Status | What it is |
|------|---------|--------|------------|
| [`astro-paper/`](./astro-paper/) | **AP** | ✅ Shipped (`baseline-v1`); not yet live | Vercel's AstroPaper template — an Astro blog with Pagefind search and build-time Open Graph images — built static and served as Cloudflare Workers Static Assets behind one Worker, and an Orun baseline that instantiates it (AP2) |

As-built ≠ intent: what shipped lives in each epic's `IMPLEMENTATION-STATUS.md`.
