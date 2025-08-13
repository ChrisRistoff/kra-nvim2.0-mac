-- https://github.com/neovim/nvim-lspc-- https://github.com/neovim/nvim-lspconfig
local M = {}

function M.setup()
    require("mason").setup({
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        }
    })

    require("mason-lspconfig").setup({
        ensure_installed = {
            "rust_analyzer",
            "lua_ls",
            "ts_ls",
            "pyright",
            "jsonls",
            "sqlls",
            "yamlls",
            "gopls",
        },
        automatic_installation = true,
    })

    -- Setup Mason-Tool-Installer for additional tools (separate from LSPs)
    -- You'll need to add this plugin: williamboman/mason-tool-installer.nvim
    local mason_tool_installer = pcall(require, "mason-tool-installer")
    if mason_tool_installer then
        require("mason-tool-installer").setup({
            ensure_installed = {
                -- Go tools
                "golines",
                "goimports",
                "golangci-lint",
                "gomodifytags",
                "gotests",
                -- Other formatters/linters
                -- "prettier", -- JS/TS formatter
                -- "eslint_d", -- JS/TS linter
                -- "black",    -- Python formatter
                -- "isort",    -- Python import sorter
                -- "stylua",   -- Lua formatter
            },
        })
    end

    local lspconfig = require("lspconfig")

    local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        local opts = { noremap = true, silent = true, buffer = bufnr }
        local keymap = vim.keymap.set

        -- Navigation
        keymap('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        keymap('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        keymap('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        keymap('n', 'gr', vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "List references" }))
        keymap('n', '<leader>D', vim.lsp.buf.type_definition,
            vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

        -- Documentation and signatures
        keymap('n', 'K', vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show hover documentation" }))
        keymap('n', '<C-k>', vim.lsp.buf.signature_help,
            vim.tbl_extend("force", opts, { desc = "Show signature information" }))

        -- Workspace management
        keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder,
            vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))
        keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder,
            vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))
        keymap('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))

        -- Code actions and refactoring
        keymap('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Show code actions" }))
        keymap('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))

        -- Formatting
        keymap('n', '<leader>fr', function()
            vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format document" }))

        -- Diagnostics (native LSP, not lspsaga)
        keymap('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Go to previous diagnostic" }))
        keymap('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Go to next diagnostic" }))
        keymap('n', '<leader>dl', vim.diagnostic.open_float,
            vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))
        keymap('n', '<leader>dq', vim.diagnostic.setloclist,
            vim.tbl_extend("force", opts, { desc = "Add diagnostics to location list" }))

        -- Print confirmation that LSP attached
        print(string.format("LSP %s attached to buffer %d", client.name, bufnr))
    end

    -- Get capabilities from cmp-nvim-lsp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Setup individual servers with correct names
    local servers = {
        -- Go
        gopls = {
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                },
            },
        },

        -- Rust
        rust_analyzer = {
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        allFeatures = true,
                    },
                    checkOnSave = {
                        command = "clippy",
                    },
                },
            },
        },

        -- Lua
        lua_ls = {
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        globals = { 'vim' },
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        },


        -- Python
        pyright = {
            settings = {
                python = {
                    analysis = {
                        typeCheckingMode = "basic",
                    },
                },
            },
        },

        -- JSON
        jsonls = {
            settings = {
                json = {
                    validate = { enable = true },
                },
            },
        },

        -- SQL
        sqlls = {},

        -- YAML
        yamlls = {
            settings = {
                yaml = {
                    keyOrdering = false,
                },
            },
        },
    }

    -- Setup each server
    for server_name, server_config in pairs(servers) do
        local config = vim.tbl_deep_extend("force", {
            on_attach = on_attach,
            capabilities = capabilities,
        }, server_config)

        lspconfig[server_name].setup(config)
    end

    -- Enable virtual text for inline diagnostics
    vim.diagnostic.config({
        virtual_text = {
            enabled = true,
            source = "if_many",
            spacing = 4,
            prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    })

    -- Setup diagnostic signs
    local signs = { Error = "󰅚", Warn = "󰀪", Hint = "󰌶", Info = "" }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
end

return M
