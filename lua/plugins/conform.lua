-- https://github.com/stevearc/conform.nvim
-- Replaces vim.lsp.buf.format — uses project-local prettier, stylua, etc.
-- Install tools: npm i -D prettier  |  pip install sqlfluff  |  cargo install stylua

return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    keys = {
        {
            "<leader>fr",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = { "n", "v" },
            desc = "Format document",
        },
    },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                javascript      = { "prettier" },
                javascriptreact = { "prettier" },
                typescript      = { "prettier" },
                typescriptreact = { "prettier" },
                json            = { "prettier" },
                yaml            = { "prettier" },
                html            = { "prettier" },
                markdown        = { "prettier" },
                sql             = { "sqlfluff" },
                lua             = { "stylua" },
            },

            -- Format on save (async to avoid blocking)
            format_on_save = function(bufnr)
                -- Disable for large files or when a flag is set
                if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
                    return
                end
                return { timeout_ms = 1500, lsp_fallback = true }
            end,

            formatters = {
                -- Use project-local prettier if present
                prettier = {
                    require_cwd = false,
                },
                sqlfluff = {
                    args = { "format", "--dialect", "ansi", "-" },
                },
            },
        })

        -- Toggle format-on-save for current buffer
        vim.keymap.set("n", "<leader>tf", function()
            vim.b.disable_autoformat = not vim.b.disable_autoformat
            vim.notify(
                "Format on save: " .. (vim.b.disable_autoformat and "OFF" or "ON"),
                vim.log.levels.INFO
            )
        end, { desc = "Toggle format on save (buffer)" })
    end,
}
