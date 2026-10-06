# fixtures/MANIFEST.md

Machine-readable record of the golden fixture and the environment that produced
it. `scripts/verify-fixture.sh` reads every expected value from here, so this
file and `fixture.pdf` are only ever updated together, by
`scripts/rebaseline.sh` (AGENTS.md §8).

Generated: 2026-10-04T06:09:05Z

## Environment

base_image: texlive/texlive@sha256:6530544393bd37b4aec8801292231ff61599aca43a04571306479a21591e87dd
texlive_version: tlmgr revision 79639 (2026-07-10 18:45:34 +0200) TeX Live (https://tug.org/texlive) version 2026
engine: This is XeTeX, Version 3.141592653-2.6-0.999998

### Debian package versions

image/Dockerfile names these packages but does not pin their versions, so a cold
rebuild resolves them against whatever Debian serves that day. These are the
versions that produced this baseline.

```
fontconfig 2.17.1-5
fonts-noto-cjk 1:20240730+repack1-1
fonts-noto-cjk-extra 1:20240730+repack1-1
fonts-noto-core 20201225-6
ghostscript 10.07.1~dfsg-1
imagemagick 8:7.1.2.31+dfsg1-1
poppler-utils 26.07.0-2
```

## Build determinism

source_date_epoch: 1789862400
render_dpi: 150

## Fixture integrity

fixture_tex_sha256: c8b3ab0985c2a3296f87906a3620a3217b22f46705ea0a97d8278aa521a97e35
fixture_pdf_sha256: 2c033061de12707203a8674eb0f38d9ac453c06c9ecdac7e0d2fae82e9046125

## Layout fingerprints

page_count: 3
page_size: 595.28 x 841.89 pts (A4)
textwidth: 483.69687pt
textheight: 702.78308pt
overfull_count: 1
overfull_signature: Overfull \hbox (73.8894pt too wide) in paragraph at lines 134--135

## Embedded font faces

```
NotoSansCJKjp-Regular
NotoSerif-Bold
NotoSerif-Regular
NotoSerifCJKjp-Bold
NotoSerifCJKjp-Regular
```
