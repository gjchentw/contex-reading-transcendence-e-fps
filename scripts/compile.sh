#!/usr/bin/env bash
# Compile a document through the compile-latex service.
#
#   scripts/compile.sh                          # src/document.tex
#   scripts/compile.sh report/main.tex          # a document under src/, relative to src/
#   scripts/compile.sh src/report/main.tex      # the same document, given as a path
#   scripts/compile.sh path/to/dir paper.tex    # explicit source tree + file
#
# A document under src/ is compiled with the whole of src/ mounted, so it can
# input files from anywhere in that tree (AGENTS.md P6). Extra latexmk flags can
# be passed via LATEXMK_ARGS. The output always lands in build/ (override with
# TEX_OUT_DIR), never next to the source.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SRC_ROOT="$CONTEX_ROOT/src"

case $# in
  0) src="$SRC_ROOT"; file="document.tex" ;;
  1) if [ -f "$SRC_ROOT/$1" ]; then
         src="$SRC_ROOT"; file="$1"
     else
         # Compare physical paths, so that reaching the repository through a
         # symlink does not make a file under src/ look like an outside one.
         abs="$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"
         src_real="$(cd "$SRC_ROOT" && pwd -P)"
         case "$abs" in
           "$src_real"/*) src="$SRC_ROOT"; file="${abs#"$src_real"/}" ;;
           *)             src="$(dirname "$abs")"; file="$(basename "$abs")" ;;
         esac
     fi ;;
  2) src="$(cd "$1" && pwd)"; file="$2" ;;
  *) echo "usage: $0 [<file.tex> | <srcdir> <file.tex>]" >&2; exit 64 ;;
esac

out="${TEX_OUT_DIR:-$CONTEX_ROOT/build}"
mkdir -p "$out"

echo "contex: compiling $file"
echo "        source $src (read-only)"
echo "        output $out"

cd "$CONTEX_ROOT"
TEX_SRC_DIR="$src" TEX_OUT_DIR="$out" TEX_FILE="$file" \
    docker compose run --rm compile-latex ${LATEXMK_ARGS:-}

echo "contex: wrote $out/$(basename "$file" .tex).pdf"
