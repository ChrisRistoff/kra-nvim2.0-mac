-- https://github.com/folke/lazydev.nvim
-- Faster, lazy Lua language server setup for editing Neovim configs.
-- Loads vim.* and plugin types only when actually needed.
-- Replaces the manual workspace.library hack in lsp_config.lua and the
-- `_G.vim = vim` workaround at the top of init.lua (kept for safety).

return {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    },
}
