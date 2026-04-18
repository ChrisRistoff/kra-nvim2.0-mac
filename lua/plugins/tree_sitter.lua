-- https://github.com/nvim-treesitter/nvim-treesitter

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            -- setup() is optional; only needed to override install_dir
            require("nvim-treesitter").setup()

            -- Install parsers (async; use :wait() only in headless/bootstrap scripts)
            require("nvim-treesitter").install({
                "c", "cpp", "php", "javascript", "typescript", "lua", "python",
                "vim", "html", "css", "json", "yaml", "prisma", "sql", "c_sharp",
                "markdown", "markdown_inline",
            })

            -- Highlighting is now provided by Neovim itself via vim.treesitter.start()
            -- Indentation is provided by nvim-treesitter via the indentexpr below
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "c", "cpp", "php", "javascript", "typescript", "lua", "python",
                    "vim", "html", "css", "json", "yaml", "prisma", "sql", "cs",
                    "markdown",
                },
                callback = function()
                    -- Enable treesitter highlighting
                    vim.treesitter.start()

                    -- Enable treesitter-based folding
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[0][0].foldmethod = "expr"
                    vim.wo[0][0].foldlevel = 99  -- start fully expanded

                    -- Enable treesitter indentation (experimental) for languages
                    -- where it works well; omit ones that were in your old disable list
                    local ft = vim.bo.filetype
                    local indent_disabled = { python = true, typescript = true, javascript = true }
                    if not indent_disabled[ft] then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@function.outer"]  = "V",
                        ["@class.outer"]     = "V",
                    },
                    include_surrounding_whitespace = false,
                },
                move = {
                    set_jumps = true,
                },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local move   = require("nvim-treesitter-textobjects.move")
            local swap   = require("nvim-treesitter-textobjects.swap")

            -- ── Select text objects ──────────────────────────────────────────
            vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end)
            vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end)
            vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer",  "textobjects") end)
            vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner",  "textobjects") end)
            vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer",     "textobjects") end)
            vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner",     "textobjects") end)

            -- ── Move between text objects ────────────────────���───────────────
            vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer",  "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer",     "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer",    "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "][", function() move.goto_next_end("@class.outer",       "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.outer",    "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer",   "textobjects") end)
            vim.keymap.set({ "n", "x", "o" }, "[]", function() move.goto_previous_end("@class.outer",      "textobjects") end)

            -- ── Swap parameters ──────────────────────────────────────────────
            vim.keymap.set("n", "<leader>a", function() swap.swap_next("@parameter.inner")     end)
            vim.keymap.set("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end)
        end,
    },
}
