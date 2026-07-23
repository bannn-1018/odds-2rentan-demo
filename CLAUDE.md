# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

A **static HTML/CSS/JS demo** of a Japanese betting/voting app (投票アプリ), covering
three games:

- `keiba/` — 競馬 (horse racing)
- `keirin/` — 競輪 (bicycle racing)
- `autorace/` — オートレース

There is **no build system, no package manager, no framework** — just hand-written
HTML pages, one shared stylesheet, and one shared script. The pages are designed to be
embedded in a native app WebView (a Flutter `flutter_inappwebview`), with a JS↔native
bridge for actions the shell handles.

## Layout

```
index.html              Landing page — pick a game
assets/
  common.css            All styles (shared by every page)
  common.js             Shared app chrome + native bridge + tab/content routing
keiba/  keirin/  autorace/
  SpRaceInfo.do.html            出走表 > 基本情報  (race card, basic info)
  SpRaceInfo2.do.html           出走表 > 前5走     (last 5 races)
  SpOddsVote.do.html            オッズ            (odds + bet selection)
  SpTipsterVote.do.html         予想              (tipster predictions)
  SpRaceResultInfo.do.html      照会・結果         (results)
  SpRaceCalendar.do.html        Race calendar
  SpCmVoteConfirm.do.html       投票内容確認       (cart / bet confirmation)
  SpCmVoteConfirmOpcoin.do.html  同上 (OP coin variant)
  S_SpRaceHeaderJPop.do.html    Race-header popup fragment
  vote_confirm_modal_*.html     Modal fragments
  ajax/
    SpZengoYosouInfo.do.html    出走表 > 前5走(縦) (loaded into the 出走表 sub-tab)
```

### The three game trees are byte-identical

`keirin/` and `autorace/` are **exact copies** of `keiba/`. The game is inferred at
runtime from `location.pathname` (see `detectContext()` in `common.js`), which also
drives the per-game brand colour.

**Consequence:** a change to any page almost always needs to be applied to **all three
copies**. When editing `keiba/SpOddsVote.do.html`, mirror the same edit into
`keirin/` and `autorace/`. Keep them identical unless a difference is intentional.

## How `common.js` works (read before touching pages)

Each page ships **only its own content** inside a single `<div class="screen">`.
`common.js` injects everything else at runtime:

- the mini-header and race header,
- the race-number tabs,
- the bottom content-nav (出走表 / オッズ / 予想 / 照会・結果),
- the 基本情報 / 前5走 / 前5走(縦) sub-tabs on 出走表 pages.

Tab switches are done by **content-only swap**, not full page loads: `common.js`
`fetch()`es the target `.do.html`, extracts its `.screen`, replaces the current content,
and re-runs the incoming page's inline `<script>` (via `runContentScripts`, because
`innerHTML` won't execute injected `<script>` tags).

- Route table: the `ROUTES` map near the top of `common.js`.
- Native bridge: `window.postToNative(action, payload)` — sends
  `{ action, payload }` as JSON through the `NativeApp` handler; falls back to
  `console.log` when no native shell is present.
- A page can override inferred context by setting `window.PAGE = {...}` **before**
  `common.js` loads.

### Clean URLs vs `.do.html`

- Anchor `href`s and `index.html` links use **clean URLs** (e.g.
  `keiba/SpRaceInfo.do`, no `.html`), which resolve on **GitHub Pages**.
- The actual fetch always appends `.html` (`fileHref`).
- `common.js` detects how the page was opened (`USES_HTML`) and mirrors that style in
  the address bar so a manual reload still resolves.

## Running / previewing locally

The pages use `fetch()` for tab swaps, so they **must be served over HTTP** — opening a
file via `file://` will break content swapping (and hit CORS).

```bash
python3 -m http.server 8000
```

Then open <http://localhost:8000/>.

> Caveat: `index.html` and anchors link to **clean** `.do` URLs, which only resolve on
> GitHub Pages. On `python3 -m http.server` those 404. To browse directly on a plain
> local server, open the `.do.html` file, e.g.
> <http://localhost:8000/keiba/SpRaceInfo.do.html>. From there the in-app tab swaps
> work, because `common.js` fetches the `.html` files.

## Conventions

- **Language:** UI text is Japanese. Keep labels, comments, and `<title>`s in Japanese
  to match the existing pages.
- **No dependencies / no tooling:** don't introduce npm, bundlers, TypeScript, or CSS
  preprocessors. Everything is plain, hand-authored HTML/CSS/JS.
- **Styling:** add to `assets/common.css`; don't inline styles unless a page already
  does so for a one-off.
- **Shared behaviour** belongs in `assets/common.js`; page-specific behaviour goes in
  that page's inline `<script>` (and must be mirrored across the three game trees).
- **No `<!DOCTYPE>`/`<html>`/`<head>`/`<body>` wrappers** in page files — they start
  straight from `<meta>` tags then a `<div class="screen">`, matching the existing pages.
