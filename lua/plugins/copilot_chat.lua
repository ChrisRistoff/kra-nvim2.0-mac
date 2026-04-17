-- https://github.com/CopilotC-Nvim/CopilotChat.nvim

return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",

        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope.nvim" },
            { "nvim-telescope/telescope-ui-select.nvim" },
        },

        opts = {
            debug = false,
            language = "English",
            model = "gpt-4o",
            resources = "buffer",
        },

        event = "VeryLazy",

        config = function(_, opts)
            -- Register telescope as vim.ui.select provider
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })
            require("telescope").load_extension("ui-select")
            require("CopilotChat").setup(opts)
        end,

        keys = {
            { "<leader>ccc", "<cmd>CopilotChat<cr>",         desc = "CopilotChat - Open" },
            { "<leader>ccr", "<cmd>CopilotChatReset<cr>",    desc = "CopilotChat - Reset" },
            { "<leader>ccm", "<cmd>CopilotChatModels<cr>",   desc = "CopilotChat - Select model" },
            { "<leader>ccp", "<cmd>CopilotChatPrompts<cr>",  desc = "CopilotChat - Prompt actions" },
            { "<leader>cce", "<cmd>CopilotChatExplain<cr>",  desc = "CopilotChat - Explain code" },
            { "<leader>cct", "<cmd>CopilotChatTests<cr>",    desc = "CopilotChat - Generate tests" },
            { "<leader>ccf", "<cmd>CopilotChatFixDiagnostic<cr>", desc = "CopilotChat - Fix diagnostic" },
        },
    },
}
