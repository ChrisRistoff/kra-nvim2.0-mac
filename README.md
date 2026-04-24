# kra-nvim2.0-mac

My personal Neovim configuration. Built around [lazy.nvim](https://github.com/folke/lazy.nvim), [mason.nvim](https://github.com/williamboman/mason.nvim) for tooling, and the new built-in `vim.lsp.config` API. Tuned for **TypeScript / Node.js**, **Python**, **Go**, **Rust**, **SQL**, and **AWS serverless** (CloudFormation / SAM).

> **Heads up — non-standard movement keys.** This config remaps HJKL on purpose. See [Movement remap](#movement-remap) before using.

---

## Table of contents

- [Requirements](#requirements)
- [Install](#install)
- [Layout](#layout)
- [Movement remap](#movement-remap)
- [General settings](#general-settings)
- [Plugins](#plugins)
  - [Core / UI](#core--ui)
  - [Editing](#editing)
  - [Completion & snippets](#completion--snippets)
  - [LSP & diagnostics](#lsp--diagnostics)
  - [Formatting & linting](#formatting--linting)
  - [Treesitter](#treesitter)
  - [Telescope (fuzzy finder)](#telescope-fuzzy-finder)
  - [Git](#git)
  - [Database](#database)
  - [TypeScript / AWS serverless](#typescript--aws-serverless)
  - [Testing](#testing)
  - [Misc QoL](#misc-qol)
- [Keymap reference](#keymap-reference)
- [Troubleshooting](#troubleshooting)

---

## Requirements

- **Neovim ≥ 0.10** (uses `vim.lsp.config`, `vim.lsp.inlay_hint`, `vim.uv`)
- `git`, `make`, a C compiler (for `telescope-fzf-native` and treesitter parsers)
- `node` (for TypeScript LSP, copilot, formatters), `npm` / `npx`
- `python3` + `pipx` (for `cfn-lint`, optional)
- `ripgrep` (`rg`) and `fd` for telescope live grep
- A Nerd Font (config uses nerd-font icons)
- macOS (some keymaps use `<D-w>` Cmd-w; trivial to swap on Linux)

For the AWS-serverless workflow:

- AWS CLI v2 + SSO configured
- AWS SAM CLI (`sam`) and/or AWS CDK
- A personal dev stack you can `sam sync --watch` to (recommended over local invoke for non-trivial Lambdas)

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim     # lazy.nvim bootstraps itself, then :Mason auto-installs LSPs
```

First launch will install all plugins, all Mason packages from `ensure_installed`, and all treesitter parsers. Give it a minute.

## Layout

```
init.lua                       -- bootstraps lazy.nvim, requires plugin specs + keymaps
lua/
  settings.lua                 -- vim options (numbers, mouse, undofile, ...)
  plugins/                     -- one file per plugin (lazy.nvim spec)
  plugins_secrets/             -- not committed; DB credentials for dadbod
  keymaps/                     -- one file per logical group of keymaps
  themes/                      -- colorscheme specs (active: gruvbox-baby)
```

## Movement remap

Defined in [`lua/keymaps/general_keymaps.lua`](lua/keymaps/general_keymaps.lua). In **normal/visual** modes:

| Key | Does                          | (Default vim)         |
|-----|-------------------------------|-----------------------|
| `h` | enter **insert** mode         | (was: move left)      |
| `j` | move **left**                 | (was: move down)      |
| `k` | move **down**                 | (was: move up)        |
| `i` | move **up**                   | (was: insert)         |

Mnemonic: index/middle/ring fingers go up-down-left/right with `i k j`, and `h` is "**h**op into insert" right under your index finger.

Other global remaps:

| Key                | Action                                       |
|--------------------|----------------------------------------------|
| `<Space>`          | `<leader>` (mapleader)                       |
| `<C-h>` / `<C-l>`  | window left / right                          |
| `Y` (normal)       | yank whole line into system clipboard (`+`)  |
| `Y` (visual)       | yank selection into system clipboard (`+`)   |
| `[` / `]` (visual) | move selected lines up / down (re-indented)  |
| `<leader>rr`       | replace all instances of word under cursor   |
| `<D-w>` (Cmd-w)    | append `;` at end of line                    |
| `dr`               | delete to end of line then enter insert      |
| `<leader>fm`       | search for `public|private` method headings  |
| `<Esc>`            | also clears search highlights                |

## General settings

From [`lua/settings.lua`](lua/settings.lua):

- Absolute + relative line numbers
- Mouse on (`mouse=a`)
- `undofile` persistent undo
- Smart-case search (`ignorecase + smartcase`)
- 250ms `updatetime`, 300ms `timeoutlen` (overridden to 200 by which-key)
- Highlight-on-yank
- UTF-8 everywhere
- Active colorscheme: **gruvbox-baby** (transparent), set in `lua/themes/gruvbox_baby.lua`

---

## Plugins

### Core / UI

| Plugin | Purpose | Key bindings |
|---|---|---|
| [folke/lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager (auto-bootstrapped) | `:Lazy` |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim) | Popup that shows pending keymap chords | Press `<leader>` then wait |
| [luisiacc/gruvbox-baby](https://github.com/luisiacc/gruvbox-baby) | Colorscheme (transparent) | `:colorscheme gruvbox-baby` |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline | — |
| [folke/noice.nvim](https://github.com/folke/noice.nvim) | Replaces `cmdline`, `messages`, `popupmenu` UI | — |
| [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer | `<F3>` toggle, `<F4>` reveal current, `<F9>` toggle gitignored |
| [petertriho/nvim-scrollbar](https://github.com/petertriho/nvim-scrollbar) | Scrollbar with diagnostic + git markers | — |
| [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indent guides | — |
| [yamatsum/nvim-cursorline](https://github.com/yamatsum/nvim-cursorline) | Highlight word under cursor | — |
| [startup-nvim/startup.nvim](https://github.com/startup-nvim/startup.nvim) | Dashboard on launch | — |

### Editing

| Plugin | Purpose | Key bindings |
|---|---|---|
| [m4xshen/autoclose.nvim](https://github.com/m4xshen/autoclose.nvim) | Auto-close brackets / quotes | — |
| [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight + search `TODO:` / `FIXME:` etc | `:TodoTelescope` |
| [AckslD/nvim-neoclip.lua](https://github.com/AckslD/nvim-neoclip.lua) | Persistent clipboard / macro history | `<leader>yy` clips, `<leader>yq` macros |
| [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live markdown preview in browser | `:MarkdownPreview` |
| [kevinhwang91/nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens) | Floating "n / N of M" search counter | uses normal `/`, `n`, `N` |

### Completion & snippets

| Plugin | Purpose |
|---|---|
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine |
| [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | LSP source |
| [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer) | Words from open buffers |
| [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path) | Filesystem paths |
| [hrsh7th/cmp-nvim-lsp-signature-help](https://github.com/hrsh7th/cmp-nvim-lsp-signature-help) | Parameter hints inline |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | LuaSnip ↔ cmp bridge |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Snippet library |
| [onsails/lspkind.nvim](https://github.com/onsails/lspkind.nvim) | VSCode-style icons in completion menu |
| [github/copilot.vim](https://github.com/github/copilot.vim) | GitHub Copilot inline suggestions (`:Copilot setup`) |

**cmp keymaps** (insert mode):

| Key            | Action                                              |
|----------------|-----------------------------------------------------|
| `<C-Space>`    | Trigger completion                                  |
| `<C-d>` / `<C-f>` | Scroll docs up / down                            |
| `<C-e>`        | Abort completion                                    |
| `<CR>`         | Confirm **only** explicitly navigated selection     |
| `<A-e>` / `<A-q>` | Next / previous item (also jumps snippet stops) |
| `<Tab>` / `<S-Tab>` | Jump forward / back through snippet placeholders |

### LSP & diagnostics

Servers managed by Mason and configured in [`lua/plugins/lsp_config.lua`](lua/plugins/lsp_config.lua):

`lua_ls`, `pyright`, `gopls`, `rust_analyzer`, `jsonls`, `yamlls`, `eslint`, `sqlls`, `cfn_lsp_extra`, plus **typescript-tools.nvim** for TS (replaces `ts_ls`).

| Plugin | Purpose |
|---|---|
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Default server configurations |
| [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) | Installer for LSPs / linters / formatters / DAPs |
| [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Bridge between Mason and lspconfig |
| [nvimdev/lspsaga.nvim](https://github.com/nvimdev/lspsaga.nvim) | Pretty UI for hover, code-actions, finder, outline, rename |
| [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim) | Per-buffer Lua LS setup with Neovim API types (replaces the old `_G.vim` workaround) |

**Native LSP keymaps** (set in `LspAttach`):

| Key | Action |
|---|---|
| `gD` | Go to declaration |
| `gd` | Go to definition |
| `gI` | Go to implementation |
| `gr` | References |
| `<C-k>` (insert) | Signature help |
| `<leader>D` | Type definition |
| `<leader>rn` | Rename |
| `<leader>fr` | Format (via conform) |
| `<leader>dl` | Open diagnostics float |
| `<leader>dq` | Diagnostics → location list |
| `<leader>ih` | Toggle inlay hints (buffer) |

**Lspsaga keymaps** (`lua/keymaps/lsp_saga_keymaps.lua`):

| Key | Action |
|---|---|
| `K` | Hover documentation |
| `<leader>ca` | Code actions (n + v) |
| `<leader>cr` | Rename symbol |
| `<leader>cR` | Rename across project |
| `<leader>co` | Outline of current file |
| `<leader>cf` | Telescope LSP references |
| `<leader>ci` | Telescope LSP implementations |
| `<leader>ct` | Peek type definition |
| `<leader>cgd` | Peek definition |
| `<leader>cgg` | Goto definition |
| `<leader>cgt` | Goto type definition |
| `<leader>ce` / `<leader>cq` | Incoming / outgoing calls |
| `<leader>cdd` | Line diagnostics |
| `<leader>cdc` | Cursor diagnostics |
| `<leader>cda` | Buffer diagnostics |
| `<leader>cdw` | Workspace diagnostics |
| `<leader>cde` / `<leader>cdq` | Prev / next diagnostic |
| `<leader>cee` / `<leader>ceE` | Next / prev **error** |
| `<leader>cww` / `<leader>cwW` | Next / prev **warning** |
| `<leader>cdf` | Native float diagnostic (fallback) |
| `<leader>ch` | Native LSP hover (fallback) |
| `<leader>ctt` | Lspsaga floating terminal |

### Formatting & linting

| Plugin | Purpose | Key bindings |
|---|---|---|
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | Format-on-save (`prettier`, `stylua`, `sqlfluff`) with project-local fallback | `<leader>fr` format buffer/selection, `<leader>tf` toggle format-on-save (buffer) |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) | Async linters: `cfn-lint` for yaml/json, `sqlfluff` for SQL | `<leader>cl` lint current buffer |

Format-on-save can be skipped per-buffer by setting `vim.b.disable_autoformat = true` (toggled with `<leader>tf`) or globally via `vim.g.disable_autoformat = true`.

### Treesitter

| Plugin | Purpose |
|---|---|
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (`main` branch) | Parsers: c, cpp, php, javascript, typescript, lua, python, vim, html, css, json, yaml, prisma, sql, c_sharp, markdown |
| [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Smart text objects |

**Textobject keymaps** (visual + operator-pending):

| Key | Object |
|---|---|
| `aa` / `ia` | parameter (around / inner) |
| `af` / `if` | function (around / inner) |
| `ac` / `ic` | class (around / inner) |
| `]m` / `[m` | next / prev function start |
| `]M` / `[M` | next / prev function end |
| `]]` / `[[` | next / prev class start |
| `][` / `[]` | next / prev class end |
| `<leader>a` / `<leader>A` | swap parameter forward / backward |

Folding uses treesitter (`foldmethod=expr`); files start fully expanded.

### Telescope (fuzzy finder)

| Plugin | Purpose |
|---|---|
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder UI |
| [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | Native FZF sorter (built with `make`) |

| Key | Action |
|---|---|
| `<leader>?` | Recently opened files |
| `<leader><space>` | Open buffers |
| `<leader>/` | Fuzzy-find inside current buffer |
| `<leader>sf` | Search files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep word under cursor |
| `<leader>sh` | Help tags |
| `<leader>sd` | Diagnostics |

### Git

| Plugin | Purpose | Key bindings |
|---|---|---|
| [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) | Git frontend (`:Git`, `:Gvdiffsplit`, `:Gwrite`, ...) | — |
| [tpope/vim-rhubarb](https://github.com/tpope/vim-rhubarb) | GitHub URLs for `:GBrowse` | — |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Sign-column hunks, blame, hunk staging | — |
| [rhysd/git-messenger.vim](https://github.com/rhysd/git-messenger.vim) | Floating popup with last commit for current line | `<leader>gg` |

**Conflict-resolution keymaps** (active in `:Gvdiffsplit!` 3-way):

| Key | Action |
|---|---|
| `<leader>gd` | Open three-way diff split |
| `<leader>gl` | Keep **local** (yours) |
| `<leader>gr` | Keep **remote** (theirs) |
| `<leader>gb` | Keep **both** |
| `<leader>gn` / `<leader>gp` | Next / prev conflict marker |

### Database

| Plugin | Purpose |
|---|---|
| [tpope/vim-dadbod](https://github.com/tpope/vim-dadbod) | DB query runner |
| [kristijanhusak/vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | Tree UI for connections / saved queries |
| [kristijanhusak/vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion) | SQL completion via cmp |

Connections live in `lua/plugins_secrets/dadbod-ui-dblist.lua` (gitignored). It must export `{ dbs = { name = "url", ... } }`.

| Key | Action |
|---|---|
| `<leader>db` | Toggle DBUI panel |
| `<leader>do` | Open DBUI |
| `<leader>da` | Add connection |
| `<leader>df` | Find current buffer in DB tree |
| **In DBUI buffers** | |
| `<leader>S` | Execute current statement |
| `<leader>W` | Save query |
| `<leader>E` | Edit saved query name |
| `<leader>R` | Rename result buffer |
| `<leader>gj` | Jump to foreign-key result |
| `[t` / `]t` | Navigate result sets |

### TypeScript / AWS serverless

These are the additions made for the AWS-serverless-with-Node workflow.

| Plugin | Why |
|---|---|
| [pmizio/typescript-tools.nvim](https://github.com/pmizio/typescript-tools.nvim) | Direct `tsserver` integration; faster than `ts_ls` on monorepos. Adds organize-imports, file-rename refactor, "go to source definition" (skip `.d.ts`), inlay hints. |
| [dmmulroy/ts-error-translator.nvim](https://github.com/dmmulroy/ts-error-translator.nvim) | Translates AWS SDK v3's monstrous generic errors into plain English. |
| [b0o/SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim) | Bundled JSON / YAML schemas: SAM, CloudFormation, `serverless.yml`, `buildspec.yml`, GitHub Actions, `package.json`, `tsconfig.json`, etc. Wired into `yamlls` + `jsonls` automatically by filename. |
| `cfn_lsp_extra` (Mason package: [cfn-lsp-extra](https://github.com/laughedelic/cfn-lsp-extra)) | Adds **completion + hover** for `AWS::*` resource properties — `cfn-lint` only validates, this autocompletes. |
| [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim) | Replaces the manual `lua_ls` workspace.library hack; loads Neovim API types only for `.lua` files in your config. |

**typescript-tools keymaps** (under `<leader>t*`):

| Key | Action |
|---|---|
| `<leader>to` | Organize imports |
| `<leader>tu` | Remove unused imports |
| `<leader>tm` | Add missing imports |
| `<leader>tR` | Rename file (updates imports project-wide) |
| `<leader>tD` | Go to source definition (skip `.d.ts`) |

**Harpoon v2** ([ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)) — pin the 4–5 files you bounce between (handlers, `template.yaml`, tests):

| Key | Action |
|---|---|
| `<leader>ha` | Add current file to list |
| `<leader>hh` | Toggle quick menu (edit list inline) |
| `<leader>1`–`<leader>5` | Jump to slot 1–5 |
| `<leader>hn` / `<leader>hp` | Next / prev pin |

### Testing

| Plugin | Purpose |
|---|---|
| [nvim-neotest/neotest](https://github.com/nvim-neotest/neotest) | Test runner UI |
| [nvim-neotest/neotest-jest](https://github.com/nvim-neotest/neotest-jest) | Jest adapter |

Keymaps under `<leader>n*`:

| Key | Action |
|---|---|
| `<leader>nt` | Run nearest test |
| `<leader>nf` | Run all tests in file |
| `<leader>nl` | Re-run last test |
| `<leader>ns` | Toggle summary sidebar |
| `<leader>no` | Open output for nearest |
| `<leader>np` | Toggle output panel |
| `<leader>nx` | Stop running test |

To switch to **vitest**, replace `neotest-jest` with [`marilari88/neotest-vitest`](https://github.com/marilari88/neotest-vitest) inside `lua/plugins/neotest.lua`. For Python Lambdas use [`nvim-neotest/neotest-python`](https://github.com/nvim-neotest/neotest-python).

### Misc QoL

Already covered above but worth calling out:

- **Inlay hints** auto-enabled on any LSP that supports them. Toggle per buffer with `<leader>ih`.
- **Format-on-save** runs async with a 1.5s timeout; toggle with `<leader>tf`.
- **Diagnostics** show inline (`virtual_text`) plus signs in the gutter, sorted by severity.

---

## Keymap reference

Quick alphabetical index of `<leader>` keymaps. Not exhaustive — see individual `lua/keymaps/*.lua` files.

| Prefix | Used by |
|---|---|
| `<leader>1`–`5` | Harpoon slots |
| `<leader>?`, `<leader><space>`, `<leader>/`, `<leader>s*` | Telescope |
| `<leader>a` / `<leader>A` | Treesitter swap parameter |
| `<leader>c*` | Lspsaga (code, diagnostics, calls, ...) |
| `<leader>cl` | nvim-lint manual lint |
| `<leader>d*` | Database UI (`db`, `do`, `da`, `df`), LSP diagnostics (`dl`, `dq`) |
| `<leader>fm` | Search method headings |
| `<leader>fr` | Format buffer (conform) |
| `<leader>g*` | Git: `gg` messenger, `gd` diff, `gl/gr/gb` conflict resolution, `gn/gp` conflict nav |
| `<leader>h*` | Harpoon: `ha`, `hh`, `hn`, `hp` |
| `<leader>ih` | Toggle inlay hints |
| `<leader>n*` | Neotest |
| `<leader>rn` | LSP rename |
| `<leader>rr` | Replace word under cursor |
| `<leader>tf` | Toggle format-on-save (buffer) |
| `<leader>to`, `<leader>tu`, `<leader>tm`, `<leader>tR`, `<leader>tD` | typescript-tools |
| `<leader>wl` | List LSP workspace folders |
| `<leader>yy` / `<leader>yq` | Neoclip / macroscope |

Press `<leader>` and wait a moment — [which-key](https://github.com/folke/which-key.nvim) will show every available chord.

---

## Troubleshooting

- **`cfn_lsp_extra` not attaching** — make sure Mason installed it (`:Mason` → search `cfn-lsp-extra`). It activates only on YAML/JSON files in projects with `template.yaml`, `template.yml`, or `samconfig.toml` at the root. Force a reload with `:e`.
- **YAML schema not detected on `template.yaml`** — SchemaStore matches by filename. If you use `template.yml` it should still match the SAM schema; for unusual filenames, add an `extra` entry in the `yamlls` config (already shows the pattern).
- **TypeScript feels slow on large repos** — typescript-tools sometimes restarts when many files change. Try `:TSToolsLogStop` then `:LspRestart`. As a fallback you can drop `typescript-tools.nvim` and add `vtsls` to `ensure_installed` in `lsp_config.lua`.
- **Inlay hints too noisy** — toggle off per-buffer with `<leader>ih`; or disable globally with `vim.lsp.inlay_hint.enable(false)` in `settings.lua`.
- **Format-on-save hangs** — bump the timeout in `lua/plugins/conform.lua` (`format_on_save` returns `{ timeout_ms = 1500 }`), or disable with `vim.g.disable_autoformat = true`.
- **Treesitter parser errors after update** — `:TSUpdate` and restart.
- **Copilot not authenticated** — run `:Copilot setup` and follow the device-code flow.

### AWS serverless workflow tips

- For the **fast inner loop**, prefer `sam sync --watch` (or `cdk watch`) deploying to a **personal dev stack**, then tail logs with `sam logs --tail` in tmux. This sidesteps `sam local` divergence (VPC, IAM, EventBridge, layers) while keeping deploys to a few seconds.
- `sam local invoke` / `start-api` is fine for pure-compute Lambdas + DynamoDB Local, less so once you involve VPC, custom auth, EventBridge, SQS triggers, or X-Ray.
- For pure handler-logic debugging, run the handler under Jest (`<leader>nt`) — no need for a DAP-attached `sam local`.

---

License: do whatever you want.
