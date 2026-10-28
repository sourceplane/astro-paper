# astro-paper — risks and open questions

| ID | Risk | State | Notes |
|---|---|---|---|
| AP-A | `baseline-v1` is not yet proven live | OPEN | Proven offline in Baseline CI: the offline bootstrap with the blueprint's own hooks, the stage lane's own steps in a staged job tree, the site served by `wrangler dev` and smoke-tested with the component's own command. A console bootstrap closes it |
| AP-B | A Worker in front of a static site | ACCEPTED | The composition deploys a Worker with its assets; this one only hands unmatched requests back to the assets. It costs nothing a request that matches a file pays: those are served without reaching it |
| AP-C | Absolute links are built in, per environment | ACCEPTED | Canonical and Open Graph links, the sitemap, robots.txt and the RSS feed carry the origin the deploy built for: the environment's `SITE_URL` (a custom domain), else its workers.dev URL. Attaching a domain is setting `SITE_URL` and merging; a local build uses `astro-paper.config.ts`'s `site.url` |
| AP-D | The tests live in the app | ACCEPTED | Astro components render only under Astro's Vite config (the container API); a `tests/web` package would need it anyway |
| AP-E | The build fetches its font over the network | ACCEPTED | Astro's Fonts API downloads Google Sans Code from Google Fonts at build time, as upstream, and the Open Graph images read it back; every lane has the network |
| AP-F | stack-tectonic 0.19.0, not 0.20.0 | ACCEPTED | 0.20.0's lane-shared install links each job's `node_modules` out of its tree; the siblings pin 0.19.0 for it and the site would save nothing |
| AP-G | The slug is the theme's own name | RESOLVED | The theme's credit is masked from the rename and allowed in the leftover sweep, each piece exactly: its repository, its config file, helper and types, the home page's sentence, and its name in its own posts and pages. Anything else spelling the slug, `AstroPaper` or `ASTRO_PAPER_` fails. `testing/rebrand.test.sh` holds both sides |
