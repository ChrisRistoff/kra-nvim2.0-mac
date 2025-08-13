return {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',    -- load when LSP attaches to a buffer
    config = function()
        require('lspsaga').setup({
            -- UI settings
            ui = {
                winblend = 10,
                border = 'rounded',
                colors = {
                    normal_bg = '#002b36'
                }
            },

            -- lightbulb for code actions
            lightbulb = {
                enable = true,
                enable_in_insert = false,
                sign = true,
                sign_priority = 10,
                virtual_text = false,
            },

            -- hover docs
            hover = {
                max_width = 0.6,
                max_height = 0.8,
                open_link = 'gx',
            },

            -- function signature help
            signature = {
                enable = true,
                auto_open = {
                    enable = true,
                    timer = 4000, -- auto close after 4 seconds
                },
            },

            -- breadcrumbs
            symbol_in_winbar = {
                enable = true,
                separator = ' › ',
                hide_keyword = true,
                show_file = true,
                folder_level = 1,
                respect_root = false,
                color_mode = true,
            },

            outline = {
                win_position = 'right',
                win_with = '',
                win_width = 30,
                preview_width = 0.4,
                show_detail = true,
                auto_preview = true,
                auto_refresh = true,
                auto_close = true,
                custom_sort = nil,
                keys = {
                    expand_or_jump = 'o',
                    quit = 'q',
                },
            },

            code_action = {
                num_shortcut = true,
                show_server_name = false,
                extend_gitsigns = true,
                keys = {
                    quit = 'q',
                    exec = '<CR>',
                },
            },

            rename = {
                quit = '<C-c>',
                exec = '<CR>',
                mark = 'x',
                confirm = '<CR>',
                in_select = false,
            },

            diagnostic = {
                on_insert = false,
                on_insert_follow = false,
                insert_winblend = 0,
                show_code_action = true,
                show_source = true,
                jump_num_shortcut = true,
                max_width = 0.7,
                max_height = 0.6,
                max_show_width = 0.9,
                max_show_height = 0.6,
                text_hl_follow = true,
                border_follow = true,
                extend_relatedInformation = true,
                keys = {
                    exec_action = 'o',
                    quit = 'q',
                    expand_or_jump = '<CR>',
                    quit_in_show = { 'q', '<ESC>' },
                },
            },

            definition = {
                edit = '<C-c>o',
                vsplit = '<C-c>v',
                split = '<C-c>i',
                tabe = '<C-c>t',
                quit = 'q',
            },

            -- references, implementations, etc.
            finder = {
                max_height = 0.5,
                keys = {
                    edit = { 'o', '<CR>' },
                    vsplit = 's',
                    split = 'i',
                    tabe = 't',
                    quit = { 'q', '<ESC>' },
                },
            },

            implement = {
                enable = false,
                sign = true,
                lang = {},
                virtual_text = true,
                priority = 56,
            },

            -- highlight cursor line after jump
            beacon = {
                enable = true,
                frequency = 7,
            },
        })

    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons'
    }
}
