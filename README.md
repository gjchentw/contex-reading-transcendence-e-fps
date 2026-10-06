# contex 範例：論文導讀《用形式冪級數證明 e 是超越數》

這個倉庫是 **contex** 範本的一個完整使用範例。

contex（**con**tainer + la**tex**）是一個版本釘死、可驗證的 Docker 環境，用來把混排正體中文、
拉丁文字與理工符號的 LaTeX 原始檔產製成 PDF。它是一個**範本倉庫**：從它建立自己的倉庫，
把文件寫在 `src/` 之下，編譯結果落在 `build/`。環境層（`image/`、`scripts/`、`fixtures/`、
`docker-compose.yml`、`src/style/contex-*.sty`）與文件層（`src/` 其餘內容）嚴格分開，
環境永遠不需要文件去遷就它。

本倉庫示範的是文件層的實際用法：拿一篇數學論文，寫一份給高中生看的導讀，並產出 PDF。

## 這個範例做了什麼

| 項目 | 位置 |
|---|---|
| 被導讀的論文原稿 | `src/cites/SFtwoP.tex`，M. Klazar, *The transcendence of e via formal power series*，[arXiv:2601.01019](https://arxiv.org/abs/2601.01019) |
| 導讀文件（LaTeX 原始檔） | `src/guide/transcendence-e-guide.tex`，各章在 `src/guide/parts/` |
| 產出的 PDF（35 頁） | `example/transcendence-e-guide.pdf` |

導讀的讀者是高中生。超出高中數學課綱的知識（代數數與超越數、廣義積分與歐拉恆等式、
形式冪級數與極點、可數與不可數等）都在第一部先行說明，再依序走過論文的三節，
全文附 18 張 TikZ 與 pgfplots 解說圖。`example/` 裡的 PDF 是讓人不必安裝 Docker 也能直接
閱讀成品；它是 `build/` 產物的複本，重新編譯後請一併更新。

## 論文出處與致謝

本範例導讀的論文為：

> Martin Klazar, *The transcendence of e via formal power series*,
> arXiv:2601.01019 [math.NT]，2026 年 1 月 3 日提交，2026 年 5 月 13 日修訂（v8）。
> <https://arxiv.org/abs/2601.01019>，DOI: <https://doi.org/10.48550/arXiv.2601.01019>

論文回顧希爾伯特對 e 是超越數的古典分析證明，再以形式冪級數給出兩個代數證明：一個是
Beukers、Bézivin 與 Robba 1990 年 Lindemann–Weierstrass 定理證明的特殊化，另一個是作者自己把
希爾伯特論證改寫成形式冪級數的版本。`src/cites/SFtwoP.tex` 是這篇論文的 LaTeX 原稿，著作權屬於
原作者；本倉庫的導讀是以它為對象撰寫的衍生說明，所有數學內容的功勞歸於原論文。

## 目錄結構

```
src/                 所有 LaTeX 原始檔，作者唯一需要工作的地方
  cites/             被導讀的論文原稿（閱讀用，不需編譯）
  guide/             導讀文件：主檔 transcendence-e-guide.tex 與 parts/ 分章
  style/             contex-cjk.sty、contex-stem.sty，以及你自己加入的樣式檔
  document.tex       contex 附的最小起始文件
example/             本範例產出的 PDF 複本
build/               每次編譯的全部輸出，git 忽略
image/               釘死版本的編譯環境（Dockerfile 與容器進入點）
scripts/             編譯、驗證、重設基準的腳本
fixtures/            環境的驗收測試（唯讀的參考文件與黃金 PDF）
```

## contex 提供什麼

- **XeLaTeX** 搭配 `babel` + `fontspec`：中英混排不需任何手動標記，依字元所屬書寫系統自動切換字型與斷行規則。
- **TeX Live 2026 `scheme-full`**：基底映像以內容摘要（digest）釘死，不會在你腳下漂移。
- **Noto Sans / Noto Serif + Noto CJK TC**：字型套件集合同樣釘死。
- **可重現的輸出**：以 `SOURCE_DATE_EPOCH` 固定 `\today`，同一份原始檔明天產出的 PDF 仍然相同。
- **真正的驗收測試**：一份中文加理工符號的壓力測試文件與黃金 PDF，逐頁做像素比對。

## 需求

主機上只需要 Docker、git，以及 `shasum`（或 `sha256sum`）。TeX Live、Ghostscript、ImageMagick
與 poppler 全部在映像裡。

## 安裝

```sh
printf 'CONTEX_UID=%s\nCONTEX_GID=%s\n' "$(id -u)" "$(id -g)" > .env
docker compose build
```

`.env` 讓編譯產物屬於你而不是 root；`scripts/` 裡的腳本會自己設定這兩個變數，所以只有直接呼叫
`docker compose` 時才需要它。

第一次建置會拉取約 2.6 GB 的 `scheme-full` TeX Live 映像，時間幾乎都花在下載，之後會快取。
`image/Dockerfile` 使用 `RUN --mount=type=cache`，需要 BuildKit（也就是有 `buildx` 外掛的
docker CLI）。`scripts/verify-fixture.sh` 與 `scripts/rebaseline.sh` 使用映像前都會重新建置，
以免驗證到過期的映像；若無法安裝 buildx，可加上 `CONTEX_SKIP_BUILD=1` 使用既有映像，腳本會明白說出它這麼做了。

## 編譯文件

編譯本範例的導讀：

```sh
scripts/compile.sh guide/transcendence-e-guide.tex   # -> build/transcendence-e-guide.pdf
cp build/transcendence-e-guide.pdf example/            # 更新 example/ 裡的複本
```

一般用法：

```sh
scripts/compile.sh                    # src/document.tex      -> build/document.pdf
scripts/compile.sh thesis/main.tex    # src/thesis/main.tex   -> build/main.pdf
```

或直接透過 compose，`TEX_FILE` 相對於 `src/`：

```sh
TEX_FILE=thesis/main.tex docker compose run --rm compile-latex
```

整個 `src/` 以**唯讀**方式掛載，所以文件可以 `\input` 樹裡任何位置的檔案（導讀就是主檔加
`parts/` 分章），而且任何東西都不可能寫到原始檔旁邊。輸出一律落在 `build/`。額外的 `latexmk`
參數經由 `LATEXMK_ARGS` 傳入。所有文件都寫進同一個 `build/`，所以不同文件的主檔請取不同名字。

## 使用樣式檔

```latex
\documentclass[11pt, a4paper]{article}
\usepackage[a4paper, margin=2cm]{geometry}   % 版面由你決定
\usepackage{contex-cjk}                      % [sans] 或 [serif]（預設）
\usepackage{contex-stem}
```

`contex-cjk.sty` 負責語言與字型，`contex-stem.sty` 載入數學、表格與圖形套件。兩者都不碰版面、
行距與縮排，那些是每份文件自己的決定。導讀的主檔示範了在此基礎上再加 `amsthm`、`pgfplots`、
`tcolorbox` 與 `hyperref` 的寫法；`scheme-full` 保證這些套件都在。

兩個樣式檔都在 `src/style/`，它在 `src/` 底下每份文件的 TeX 搜尋路徑上；你自己的 `.sty`、`.cls`
也放這裡。

## 驗證環境

```sh
scripts/verify-fixture.sh
```

編譯 `fixtures/fixture.tex` 並與黃金 `fixtures/fixture.pdf` 比對：先檢查便宜的指紋（頁數與頁面大小、
`\textwidth`、唯一一個 overfull hbox 的精確數值、PDF 內嵌的字型集合），再逐頁做像素比對，
要求零個相異像素。只要指紋移動就停在渲染之前，因為環境已經不同了，像素比對只會更慢地說同一件事。
改動映像或樣式檔之後都要跑一次。

如果你刻意改了環境、輸出合理地改變了：

```sh
CONTEX_REBASELINE=i-understand scripts/rebaseline.sh
```

本範例只新增文件層的檔案，沒有動到環境層，因此不需要重設基準。

## 給 AI 代理人

先讀 [AGENTS.md](AGENTS.md)。它是規範性的文件，同時載有在不破壞環境保證的前提下工作所需的規則與背景知識。
