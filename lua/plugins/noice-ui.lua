return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            { "rcarriga/nvim-notify", opts = { background_colour = "#000000" } },
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
                    position = { row = 1, col = "100%" },
                    size = { width = "auto", height = "auto" },
                    border = { style = "rounded" },
                    win_options = { winblend = 0 },
                },
            },
            routes = {
                {
                    filter = { event = "msg_show", find = "deprecated" },
                    view = "notify",
                },
                {
                    filter = { event = "msg_show", kind = "", find = "%d+" },
                    view = "mini",
                },
                {
                    filter = { event = "msg_show", kind = "" },
                    opts = { skip = true },
                },
                {
                    filter = { event = "notify" },
                    view = "notify",
                },
            },
            lsp = {
                progress = {
                    enabled = true,
                    view = "mini",       -- shows in top-right like other popups, not bottom
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
