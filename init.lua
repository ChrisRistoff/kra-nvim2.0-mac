--  Author: Krasen Hristov

-- Tell the Lua language server that `vim` is a global variable
_G.vim = vim

-- setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- info: require where plugins > 1
local git_related = require("plugins.git_related")
local mason = require("plugins.mason")

-- info: Setup the plugins
require("lazy").setup({
    -- ==============
    -- THEME
    -- ==============
    -- require("themes.night_owl"), -- for night
    -- require("themes.evergarden"), -- for morning
    -- require("themes.calvera"),
    require("themes.gruvbox_baby"),

    -- ==============
    -- LSP / MASON
    -- ==============
    mason[1],
    mason[2],
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("plugins.lsp_config").setup()
        end,
    },
    require("plugins.lsp_saga"),
    require("plugins.lazydev"),

    -- ==============
    -- COMPLETION / SNIPPETS
    -- ==============
    require("plugins.cmp"),
    require("plugins.lua_snip"),
    require("plugins.friendly_snippets"),
    require("plugins.copilot"),

    -- ==============
    -- TREESITTER / SYNTAX
    -- ==============
    require("plugins.tree_sitter"),

    -- ==============
    -- FORMATTING / LINTING
    -- ==============
    require("plugins.conform"),
    require("plugins.nvim_lint"),

    -- ==============
    -- LANGUAGE-SPECIFIC (TS / AWS / SCHEMAS)
    -- ==============
    require("plugins.ts_error_translator"),
    require("plugins.schemastore"),

    -- ==============
    -- TESTING
    -- ==============
    require("plugins.neotest"),

    -- ==============
    -- FILE NAVIGATION
    -- ==============
    require("plugins.nvim_tree"),
    require("plugins.harpoon"),
    require("plugins.telescope"),

    -- ==============
    -- GIT
    -- ==============
    git_related[1], -- vim fugitive
    git_related[2], -- vim rhubarb
    require("plugins.git_signs"),
    require("plugins.git_messenger"),

    -- ==============
    -- DATABASE
    -- ==============
    require("plugins.vim-dadbod-ui"),

    -- ==============
    -- EDITING UTILITIES
    -- ==============
    require("plugins.autoclose_brackets"),
    require("plugins.TODO_comments"),
    require("plugins.neoclip"),

    -- ==============
    -- UI / VISUAL
    -- ==============
    require("plugins.lua_line"),
    require("plugins.indent_line"),
    require("plugins.hlslens"),
    require("plugins.cursorline"),
    require("plugins.scrollbar"),
    require("plugins.noice-ui"),
    require("plugins.startup"),
    require("plugins.which_key"),

    -- ==============
    -- MARKDOWN
    -- ==============
    require("plugins.markdown_preview"),
})

-- ==============
-- SETTINGS
-- ==============
require("settings")

-- ==============
-- KEYMAPS
-- ==============
require("keymaps.general_keymaps")
require("keymaps.nvim_tree_keymaps")
require("keymaps.fzf_keymaps")
require("keymaps.lsp_saga_keymaps")
require("keymaps.neoclip_keymaps")
require("keymaps.git_keymaps")
require("keymaps.dadbod_keymaps")
require("keymaps.harpoon_keymaps")
require("keymaps.neotest_keymaps")
