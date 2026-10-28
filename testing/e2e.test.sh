#!/usr/bin/env bash
# TIER 2 — the site a bootstrap produces builds, deploys (dry) and serves.
#
# placement.test.sh proves the tree a bootstrap ends with is the right tree.
# This proves it WORKS, by doing to it what its own pipelines will:
#
#   1. at the finished site, the landing's own checks — install with the
#      lockfile the site ships, render fixtures, typecheck, lint, test,
#      build. The bootstrap's own landings are checked in the box with
#      `orun validate` and `orun plan` alone (`checks: local`; their PR's CI
#      on an `orun/BASE-…` branch is `plan` alone, and the convergence on
#      main builds, deploys and smoke-tests the site), and a later pull
#      request of the site runs ci.yml's verify lanes, which build and
#      dry-deploy it — so THIS is where the site's type-check, lint and tests
#      run before it ships: before the tag, not after a build has merged it;
#   2. the stage lane's own steps, rendered by `orun plan` in the site: on a
#      pull request (the verify profile) `verify-app-structure` (the deploy
#      config must exist BEFORE the build), `build-app` — the component's
#      buildCommand, the same step the deploy profile runs —
#      `verify-build-output` and `deploy-dry-run` (`wrangler deploy --dry-run
#      --config <wranglerConfig> --name <reponame>-web-stage`). They run IN THE
#      TREE THE RUNNER STAGES for the job (testing/lib/stage-job.py), with the
#      dependency layout the pinned composition produces: if its install step
#      is `scope: lane`, the top-level node_modules is a symlink to the source
#      checkout's; if not, the job's own install step runs inside the staged
#      tree. A staged tree has no dist/, which is what makes the structure
#      and output checks honest: the config the lane deploys is committed, the
#      Worker entry is a source file, and dist/ is what the build just wrote;
#   3. serve the built Worker with `wrangler dev` over the component's own
#      wranglerConfig and run the component's OWN `smokeCommand` against it,
#      verbatim — the check the real deploy ends with — and then read every
#      route the site promises: the home page, the header and every page's
#      title carry the site's name; the posts index (and its second page), a
#      post, a release post at its own URL, the tag and archive pages, the
#      search page and the Pagefind index it loads; each post's Open Graph
#      image and the site's, named in their pages; the RSS feed, the sitemap
#      and robots.txt, all on the stage origin; a page without its trailing
#      slash redirected to it; and an unknown path is the site's own 404 page
#      with a 404 status.
#
# What it cannot do is the platform's half: create the repository, mint the
# brokered Cloudflare token, deploy for real and probe workers.dev. That is a
# bootstrap against a workspace (BOOTSTRAP.md); everything short of it is here.
#
# Needs: orun, node, pnpm, python3 (+PyYAML), git, curl, and the network for
# `pnpm install` (or a warm store). A few minutes: two installs and builds
# (the landing's checks over the site, and the stage lane's own in its staged
# tree).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
# shellcheck source=lib/bootstrap.sh
source "$here/lib/bootstrap.sh"

for bin in orun node pnpm python3 git curl; do
  command -v "$bin" >/dev/null || { echo "e2e.test.sh needs $bin on PATH" >&2; exit 1; }
done

scratch="$(mktemp -d)"
dev_pid=""
# wrangler dev runs under pnpm, node and two workerd processes; a TERM to the
# first does not reach the rest, and waiting on it then never returns. So it is
# started as its own process group (setsid) and the whole group is stopped.
cleanup() {
  if [ -n "$dev_pid" ]; then
    kill -TERM -- "-$dev_pid" 2>/dev/null || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do kill -0 -- "-$dev_pid" 2>/dev/null || break; sleep 0.5; done
    kill -KILL -- "-$dev_pid" 2>/dev/null || true
  fi
  rm -rf "$scratch"
}
trap cleanup EXIT
values="$here/fixtures/acme.json"
repo="$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['reponame'])" "$values")"
export CI=1 WRANGLER_SEND_METRICS=false ASTRO_TELEMETRY_DISABLED=1 TURBO_TELEMETRY_DISABLED=1

# The landing's own checks, step for step, run here at once on the whole
# tree. A pull request in the site builds and dry-deploys it through ci.yml's
# lanes; the type-check, the lint and the tests run here, and by hand before
# a push.
LANDING_CHECKS=(
  "pnpm install --frozen-lockfile"
  "pnpm run wire:fixture"
  "pnpm typecheck"
  "pnpm lint"
  "pnpm test"
  "pnpm build"
)
checks() { # DIR LOG
  local dir="$1" log="$2" cmd
  for cmd in "${LANDING_CHECKS[@]}"; do
    echo "   \$ $cmd" | tee -a "$log"
    if ! (cd "$dir" && bash -c "$cmd") >> "$log" 2>&1; then
      echo "FAIL: \`$cmd\` failed in $dir" >&2; tail -40 "$log" >&2; return 1
    fi
  done
}

echo "── the offline bootstrap (testing/lib/bootstrap.sh)"
tree="$scratch/$repo"
bootstrap_offline "$root" "$tree" "$values" "$scratch/logs" > "$scratch/bootstrap.log" 2>&1 || {
  echo "FAIL: the offline bootstrap stopped" >&2; tail -40 "$scratch/bootstrap.log" >&2; exit 1; }
echo "   2 phases placed and landed"

# ── 1. the finished site ───────────────────────────────────────────────────
echo "── the finished site: install, the fixture render, typecheck, lint, test, build"
checks "$tree" "$scratch/checks-site.log"

# ── 2. the deploy lane's steps, for stage ──────────────────────────────────
echo "── the stage lane: verify-app-structure, build-app, verify-build-output, deploy-dry-run"
# The 01-product landing over the repository's empty first commit: every file
# of the site changed, as on its pull request.
s00="$(git -C "$tree" rev-parse HEAD~2)"; s01="$(git -C "$tree" rev-parse HEAD~1)"
(cd "$tree" && orun plan --intent intent.yaml --trigger github-pull-request --changed \
   --base "$s00" --head "$s01" --env stage --output "$scratch/plan.json") > "$scratch/plan.log" 2>&1 \
  || { echo "FAIL: orun plan" >&2; tail -15 "$scratch/plan.log" >&2; exit 1; }
python3 - "$scratch/plan.json" "$scratch/steps" <<'PY'
import json, pathlib, sys
plan = json.load(open(sys.argv[1]))
out = pathlib.Path(sys.argv[2]); out.mkdir()
job = next(j for j in plan["jobs"] if j["component"] == "web" and j["environment"] == "stage")
for s in job["steps"]:
    if s["id"] in ("verify-app-structure", "build-app", "verify-build-output", "deploy-dry-run"):
        (out / f"{s['id']}.sh").write_text(s.get("run") or "")
    if s["id"] == "install-workspace-dependencies":
        (out / "install.sh").write_text(s.get("run") or "")
        (out / "install.wd").write_text(s.get("working-directory") or ".")
        (out / "install.scope").write_text(s.get("scope") or "job")
(out / "path").write_text(job.get("path") or "apps/web")
for k, v in (job.get("env") or {}).items():
    (out / "env").open("a").write(f"export {k}={json.dumps(v)}\n")
PY
# The job's private tree, staged as orun stages it. The source checkout
# carries no build output (a CI checkout has none, so the plain-tree build's is
# removed rather than copied in), and its dependencies are what the pinned
# composition says: a lane-scoped install ran once in the source tree (step 1
# ran the same command) and is linked in, or the job installs its own.
rm -rf "$tree/apps/web/dist" "$tree/apps/web/.wrangler"
work="$tree/.orun/runs/e2e/web.stage.verify-deploy/work"
[ -f "$scratch/steps/install.sh" ] || { echo "FAIL: the stage lane has no install step" >&2; exit 1; }
if [ "$(cat "$scratch/steps/install.scope")" = lane ]; then
  python3 "$here/lib/stage-job.py" "$tree" "$work" --shared-deps
  [ -L "$work/node_modules" ] || { echo "FAIL: the staged tree's node_modules is not the lane's symlink" >&2; exit 1; }
  echo "   staged: $(realpath --relative-to="$tree" "$work"); install scope: lane — node_modules → the source tree's"
else
  python3 "$here/lib/stage-job.py" "$tree" "$work"
  echo "   staged: $(realpath --relative-to="$tree" "$work"); install scope: job — installing inside it"
  echo "   ▸ install-workspace-dependencies"
  (cd "$work/$(cat "$scratch/steps/path")/$(cat "$scratch/steps/install.wd")" && bash -e "$scratch/steps/install.sh") \
    > "$scratch/install.log" 2>&1 || { echo "FAIL: the lane's install step" >&2; tail -30 "$scratch/install.log" >&2; exit 1; }
  [ -d "$work/node_modules" ] && [ ! -L "$work/node_modules" ] \
    || { echo "FAIL: the job's install did not land inside its own tree" >&2; exit 1; }
fi
for step in verify-app-structure build-app verify-build-output deploy-dry-run; do
  [ -f "$scratch/steps/$step.sh" ] || { echo "FAIL: the stage verify lane has no $step step" >&2; exit 1; }
  echo "   ▸ $step"
  # The runner's per-job environment: the job's env (intent environment
  # `env:`) and ORUN_ENVIRONMENT; the step runs in the component's directory.
  if ! (cd "$work/$(cat "$scratch/steps/path")" && \
        { [ -f "$scratch/steps/env" ] && source "$scratch/steps/env"; true; } && \
        export ORUN_ENVIRONMENT=stage && bash -e "$scratch/steps/$step.sh") > "$scratch/$step.log" 2>&1; then
    echo "FAIL: the deploy lane's $step step" >&2; tail -40 "$scratch/$step.log" >&2; exit 1
  fi
done

# What the deploy would upload: the Worker bundled from its source entry, and
# the static build beside it as assets.
grep -q 'Total Upload' "$scratch/deploy-dry-run.log" || { echo "FAIL: the dry run listed no Worker upload" >&2; tail -20 "$scratch/deploy-dry-run.log" >&2; exit 1; }
cfg="$(python3 -c "import yaml,sys;print(yaml.safe_load(open(sys.argv[1]))['spec']['parameters']['wranglerConfig'])" "$tree/apps/web/component.yaml")"

# ── 3. serve it, and smoke it as the deploy does ───────────────────────────
echo "── wrangler dev over the built Worker ($cfg)"
port=$(python3 -c "import socket;s=socket.socket();s.bind(('127.0.0.1',0));print(s.getsockname()[1]);s.close()")
(cd "$work/apps/web" && exec setsid pnpm exec wrangler dev --config "$cfg" --ip 127.0.0.1 --port "$port" \
   --name "$repo-web-stage" --show-interactive-dev-session=false) > "$scratch/dev.log" 2>&1 < /dev/null &
dev_pid=$!
url="http://127.0.0.1:$port"
for _ in $(seq 1 90); do
  curl -s -o /dev/null "$url/" && break
  kill -0 "$dev_pid" 2>/dev/null || { echo "FAIL: wrangler dev exited" >&2; tail -30 "$scratch/dev.log" >&2; exit 1; }
  sleep 1
done
curl -s -o /dev/null "$url/" || { echo "FAIL: wrangler dev never answered" >&2; tail -30 "$scratch/dev.log" >&2; exit 1; }

echo "   ▸ the component's own smokeCommand, DEPLOYED_URL=$url"
smoke="$(python3 -c "import yaml,sys;print(yaml.safe_load(open(sys.argv[1]))['spec']['parameters']['smokeCommand'])" "$tree/apps/web/component.yaml")"
DEPLOYED_URL="$url" bash -c "$smoke" || { echo "FAIL: the deploy's smoke refused the site" >&2; exit 1; }

echo "   ▸ every route the site promises"
python3 - "$url" "$values" <<'PY'
import html, json, re, sys, urllib.error, urllib.parse, urllib.request
base, values = sys.argv[1], json.load(open(sys.argv[2]))
name, repo = values["productname"], values["reponame"]
# The origin the stage lane built for: its workers.dev URL (no SITE_URL set).
origin = f"https://{repo}-web-stage.{values['subdomain']}.workers.dev"
problems = []
def bad(m): problems.append(m)
class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a, **k): return None
opener = urllib.request.build_opener(NoRedirect)
def get(path):
    try:
        with opener.open(urllib.parse.urljoin(base + "/", path), timeout=30) as r:
            return r.status, r.headers, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.headers, e.read()
def title(page):
    m = re.search(r"<title>(.*?)</title>", page, re.S)
    return html.unescape(m.group(1)) if m else None

# / — the theme's home page, under the site's name in the header.
status, headers, body = get("/")
page = body.decode()
if status != 200:
    bad(f"/ answered {status}")
if "minimal, responsive, accessible and SEO-friendly" not in page:
    bad("the home page is not the theme's (no 'minimal, responsive, accessible and SEO-friendly' introduction)")
if title(page) != name:
    bad(f"the home page's <title> is {title(page)!r}, not {name!r}")
header = re.search(r"<header.*?</header>", page, re.S)
if not header or name not in html.unescape(re.sub(r"<[^>]+>", " ", header.group(0))):
    bad(f"the header does not say {name!r}")
if f'<link rel="canonical" href="{origin}/">' not in page:
    bad(f"the home page's canonical link is not {origin}/, the origin the stage lane built for")
site_name = re.search(r'<meta property="og:site_name" content="([^"]*)"', page)
if not site_name or html.unescape(site_name.group(1)) != name:
    bad(f"the home page's og:site_name is {site_name and html.unescape(site_name.group(1))!r}, not {name!r}")

# Pages under the title "<page> | <name>".
for path, heading in (("/posts/", "Posts"), ("/tags/", "Tags"), ("/archives/", "Archives"),
                      ("/search/", "Search"), ("/about/", "About")):
    s, h, b = get(path)
    t = title(b.decode())
    if s != 200 or t != f"{heading} | {name}":
        bad(f"{path} answered {s} titled {t!r}, not '{heading} | {name}'")

# The posts: the index lists the theme's configuration post, which renders
# with its own Open Graph image; the second page and a release post answer.
s, h, b = get("/posts/")
post = "/posts/how-to-configure-astropaper-theme/"
if post not in b.decode():
    bad(f"/posts/ does not list {post}")
s, h, b = get(post)
page = b.decode()
if s != 200 or title(page) != f"How to configure AstroPaper theme | {name}":
    bad(f"{post} answered {s} titled {title(page)!r}")
og = re.search(r'<meta property="og:image" content="([^"]+)"', page)
if not og or og.group(1) != f"{origin}{post}index.png":
    bad(f"{post}'s og:image is {og and og.group(1)!r}, not its own image on {origin}")
s, h, b = get(f"{post}index.png")
if s != 200 or h.get("content-type") != "image/png" or not b.startswith(b"\x89PNG"):
    bad(f"{post}index.png answered {s} {h.get('content-type')}")
for path in ("/posts/2/", "/posts/astro-paper-v6/", "/posts/examples/tailwind-typography/", "/tags/docs/"):
    s, _, _ = get(path)
    if s != 200:
        bad(f"{path} answered {s}")

# The site's own Open Graph image, rendered for its name at build time.
s, h, b = get("/og.png")
if s != 200 or h.get("content-type") != "image/png" or not b.startswith(b"\x89PNG"):
    bad(f"/og.png answered {s} {h.get('content-type')}")

# Search: the page loads Pagefind's UI, and the index it reads is served.
s, h, b = get("/search/")
if "pagefind" not in b.decode():
    bad("/search/ does not load Pagefind")
for path in ("/pagefind/pagefind.js", "/pagefind/pagefind-ui.js", "/pagefind/pagefind-entry.json"):
    s, _, _ = get(path)
    if s != 200:
        bad(f"{path} answered {s} — the search index is not deployed")

# Feeds and crawlers, on the stage origin.
s, h, b = get("/rss.xml")
feed = b.decode()
if s != 200 or "<rss" not in feed or f"{origin}{post}" not in feed:
    bad(f"/rss.xml answered {s} without the posts on {origin}")
channel = re.search(r"<channel><title>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</title>", feed)
if not channel or html.unescape(channel.group(1)) != name:
    bad(f"/rss.xml is titled {channel and html.unescape(channel.group(1))!r}, not {name!r}")
s, h, b = get("/sitemap-index.xml")
if s != 200 or f"{origin}/sitemap-0.xml" not in b.decode():
    bad(f"/sitemap-index.xml answered {s} without the site's sitemap")
s, h, b = get("/robots.txt")
if s != 200 or f"Sitemap: {origin}/sitemap-index.xml" not in b.decode():
    bad(f"/robots.txt answered {s} without the site's sitemap line")

# Directory pages, as the theme links them: /about redirects to /about/.
s, h, _ = get("/about")
if s not in (301, 307, 308) or not (h.get("location") or "").endswith("/about/"):
    bad(f"/about answered {s} → {h.get('location')!r}, not a redirect to /about/")

# An unknown path: the site's own 404 page, with a 404.
s, h, b = get("/no-such-page")
if s != 404 or title(b.decode()) != f"404 Not Found | {name}":
    bad(f"/no-such-page answered {s} titled {title(b.decode())!r}")

if problems:
    for p in problems:
        print(f"  ✕ {p}", file=sys.stderr)
    sys.exit(1)
print(f"   /, the pages, the posts and a post with its OG image, tags, archives, search and its index, the feeds, directory URLs and the 404 — the site's own, named {name!r}")
PY

echo "e2e.test.sh: ok"
