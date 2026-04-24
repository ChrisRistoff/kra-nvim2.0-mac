-- https://github.com/nvim-neotest/neotest
-- Run unit tests from the buffer (jest/vitest for Node Lambdas).
-- Adapter: https://github.com/nvim-neotest/neotest-jest

return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/nvim-nio",
        "nvim-neotest/neotest-jest",
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-jest")({
                    jestCommand = "npx jest --",
                    jestConfigFile = function(file)
                        if string.find(file, "/packages/") then
                            return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
                        end
                        return vim.fn.getcwd() .. "/jest.config.ts"
                    end,
                    env = { CI = true },
                    cwd = function() return vim.fn.getcwd() end,
                }),
            },
            output = { open_on_run = true },
            quickfix = { enabled = false },
        })
    end,
}
