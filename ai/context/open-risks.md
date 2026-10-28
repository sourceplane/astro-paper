# astro-paper — open risks

What is not yet proven or not yet decided. The full write-up of every risk,
including the accepted and resolved ones, is
`specs/epics/astro-paper/risks-and-open-questions.md`; this page lists
only what is still live, so it should be short.

| ID | Risk | State | What closes it |
|---|---|---|---|
| AP-A | `baseline-v1` is not yet proven live; it is proven offline in Baseline CI (the offline bootstrap, the stage lane's own steps, the site served and smoke-tested) | OPEN | One console bootstrap from `baseline-v1` |

Accepted, and worth knowing before you change them: AP-B (a Worker in front
of a static site), AP-C (absolute links are built in, per environment), AP-D
(the tests live in the app), AP-E (the build fetches its font over the
network), AP-F (stack-tectonic 0.19.0), AP-G (the slug is the theme's name).
