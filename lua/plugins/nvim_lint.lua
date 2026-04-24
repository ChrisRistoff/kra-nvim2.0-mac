-- https://github.com/mfussenegger/nvim-lint

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
        local lint = require("lint")
        local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

        -- Point directly at Mason-installed binaries to avoid PATH lookup issues
        lint.linters.sqlfluff.cmd  = mason_bin .. "sqlfluff"
        lint.linters.sqlfluff.args = { "lint", "--dialect", "postgres", "--format=json", "--disable-progress-bar", "-" }

        lint.linters.cfn_lint = lint.linters.cfn_lint or {}
        if lint.linters.cfn_lint.cmd then
            lint.linters.cfn_lint.cmd = mason_bin .. "cfn-lint"
        end

        lint.linters_by_ft = {
            yaml = { "cfn_lint" },
            json = { "cfn_lint" },
            sql  = { "sqlfluff" },
        }

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
            group = vim.api.nvim_create_augroup("NvimLintAuto", { clear = true }),
            callback = function()
                lint.try_lint(nil, { ignore_errors = true })
            end,
        })

        vim.keymap.set("n", "<leader>cl", function()
            lint.try_lint()
        end, { desc = "Run cfn-lint / sqlfluff on buffer" })
    end,
}
