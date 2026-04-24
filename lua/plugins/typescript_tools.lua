-- https://github.com/pmizio/typescript-tools.nvim
-- Faster TypeScript LS that talks to tsserver directly (no Node wrapper).
-- Replaces ts_ls. Adds: organize-imports, file-rename refactor that updates
-- imports across the project, "go to source definition" (skip .d.ts),
-- tunable inlay hints.

return {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
        require("typescript-tools").setup({
            settings = {
                expose_as_code_action = "all",
                tsserver_file_preferences = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                    includeCompletionsForModuleExports = true,
                    quotePreference = "auto",
                },
                tsserver_format_options = {
                    allowIncompleteCompletions = false,
                    allowRenameOfImportPath = true,
                },
                complete_function_calls = true,
                include_completions_with_insert_text = true,
                code_lens = "off",
            },
        })

        local map = vim.keymap.set
        map("n", "<leader>to", "<cmd>TSToolsOrganizeImports<CR>",      { desc = "TS: Organize imports" })
        map("n", "<leader>tu", "<cmd>TSToolsRemoveUnusedImports<CR>",  { desc = "TS: Remove unused imports" })
        map("n", "<leader>tm", "<cmd>TSToolsAddMissingImports<CR>",    { desc = "TS: Add missing imports" })
        map("n", "<leader>tR", "<cmd>TSToolsRenameFile<CR>",           { desc = "TS: Rename file (updates imports)" })
        map("n", "<leader>tD", "<cmd>TSToolsGoToSourceDefinition<CR>", { desc = "TS: Go to source definition (skip .d.ts)" })
    end,
}
