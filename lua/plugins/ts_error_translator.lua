-- https://github.com/dmmulroy/ts-error-translator.nvim
-- Translates cryptic TypeScript errors (especially AWS SDK v3 generics) into
-- plain English diagnostics. Zero-config.

return {
    "dmmulroy/ts-error-translator.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
        require("ts-error-translator").setup({
            auto_override_publish_diagnostics = true,
        })
    end,
}
