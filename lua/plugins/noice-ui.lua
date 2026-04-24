return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            {
                "rcarriga/nvim-notify",
                opts = {
                    background_colour = "#000000",
                    render = "compact", -- single-line, less vertical space
                    timeout = 2000, -- auto-dismiss after 2s
                    max_width = 50,
                    top_down = false, -- stack from bottom-right up
                },
            },
        },
        keys = {
            { "<leader>fn", "<cmd>Noice telescope<cr>", desc = "Noice message history" },
        },
        config = function(_, opts)
            require("noice").setup(opts)
            require("telescope").load_extension("noice")
        end,
        opts = {
            views = {
                mini = {
                    position = { row = -2, col = "100%" }, -- bottom-right, 2 rows from edge
                    size = { width = "auto", height = "auto" },
                    border = { style = "none" }, -- no border = less visual noise
                    win_options = { winblend = 20 }, -- slight transparency
                    timeout = 3000,
                },
                notify = {
                    timeout = 2000,
                },
            },
            routes = {
                -- Route LSP loading progress to mini (bottom-right)
                {
                    filter = { event = "lsp", kind = "progress" },
                    view = "mini",
                },
                {
                    filter = { event = "msg_show", find = "deprecated" },
                    opts = { skip = true },
                },
                -- Show search count (e.g. "3/12") in mini
                {
                    filter = { event = "msg_show", kind = "", find = "%d+" },
                    view = "mini",
                },
                -- Skip all other blank-kind messages (write confirmations, etc.)
                {
                    filter = { event = "msg_show", kind = "" },
                    opts = { skip = true },
                },
                -- Route all notify() calls through mini instead of the big notify popup
                {
                    filter = { event = "notify" },
                    view = "mini",
                },
            },
            lsp = {
                progress = {
                    enabled = true,  -- show LSP loading progress in the mini popup
                },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },

            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
            },
        },
    },
}
