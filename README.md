# contex

**con**tainer + la**tex** — a pinned, verifiable Docker environment for producing PDFs from
LaTeX sources that mix Traditional Chinese with Latin text and STEM notation.

It is a **template repository**. Create your own repository from it, write your LaTeX under
`src/`, and build into `build/`:

```
src/            your documents and styles — the only place LaTeX source lives
  document.tex    a starter document; replace it with your own
  style/          contex-cjk.sty, contex-stem.sty, and any style files you add
build/          everything a compilation produces; git-ignored
image/          the pinned build environment
scripts/        compile, verify, re-baseline
fixtures/       the acceptance test for the environment
```

The environment never needs your document to accommodate it.

## What it gives you

- **XeLaTeX** with `babel` + `fontspec` so mixed CJK/Latin text needs no manual markup
- **TeX Live 2026 `scheme-full`**, from a base image pinned by content digest, so nothing drifts under you
- **Noto Sans / Noto Serif + Noto CJK TC**, pinned as a package set
- **Reproducible output** via `SOURCE_DATE_EPOCH`, so `\today` does not change your PDF
- **A real acceptance test**: a CJK + STEM stress fixture with a golden PDF, verified page by
  page at the pixel level

## Requirements

Docker, git, and `shasum` (or `sha256sum`). Nothing else — TeX Live, Ghostscript, ImageMagick
and poppler all live inside the image.

## Setup

```sh
printf 'CONTEX_UID=%s\nCONTEX_GID=%s\n' "$(id -u)" "$(id -g)" > .env
docker compose build
```

The `.env` step makes build artifacts owned by you rather than by root. The scripts in
`scripts/` set it themselves, so it only matters for bare `docker compose` calls.

The first build pulls a ~2.6 GB `scheme-full` TeX Live image, so expect it to be dominated by
download time. It is cached afterwards.

`image/Dockerfile` uses `RUN --mount=type=cache` so that an interrupted apt download resumes
instead of restarting, which **requires BuildKit** — i.e. a docker CLI with the `buildx`
plugin. Without it `docker compose build` falls back to the classic builder and fails on that
layer. `scripts/verify-fixture.sh` and `scripts/rebaseline.sh` rebuild the image before they
use it, so that neither can certify a stale one; if you cannot install buildx, run them with
`CONTEX_SKIP_BUILD=1` to use the already-built image, which they will say they are doing.

## Compiling a document

```sh
scripts/compile.sh                    # src/document.tex  ->  build/document.pdf
scripts/compile.sh thesis/main.tex    # src/thesis/main.tex  ->  build/main.pdf
```

Or through compose directly, with `TEX_FILE` relative to `src/`:

```sh
TEX_FILE=thesis/main.tex docker compose run --rm compile-latex
```

The whole of `src/` is mounted **read-only**, so a document can input files from anywhere in
it, and nothing can be written next to your source. Output always lands in `build/`, which git
ignores. Extra `latexmk` flags go through `LATEXMK_ARGS`.

Every document writes into the same `build/` directory, so give the main files of different
documents different names.

## Using the style files

```latex
\documentclass[11pt, a4paper]{article}
\usepackage[a4paper, margin=2cm]{geometry}   % page layout stays yours
\usepackage{contex-cjk}                      % [sans] or [serif] (default)
\usepackage{contex-stem}
```

`contex-cjk.sty` sets up languages and fonts. `contex-stem.sty` loads the maths, table and
figure packages. Neither touches page layout, line spacing or indentation — those are
per-document decisions. See `src/document.tex`.

Both live in `src/style/`, which is on the TeX search path for every document under `src/`.
Put your own `.sty` and `.cls` files there too.

## Verifying the environment

```sh
scripts/verify-fixture.sh
```

Compiles `fixtures/fixture.tex` and compares it against the golden `fixtures/fixture.pdf`:
cheap fingerprints first (page count and size, `\textwidth`, the exact overfull-hbox
magnitude, and the set of font faces the PDF embedded), then a per-page pixel diff requiring
zero differing pixels. If a fingerprint moved, it stops before rendering — the environment
already differs, and a pixel diff would only say so more slowly. Run it after any change to
the image or the style files.

If you deliberately changed the environment and the output legitimately moved:

```sh
CONTEX_REBASELINE=i-understand scripts/rebaseline.sh
```

## For AI agents

Read [AGENTS.md](AGENTS.md) first. It is normative, and it carries both the rules and the
background knowledge needed to work on this environment without breaking its guarantees.
