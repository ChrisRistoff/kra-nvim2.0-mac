-- https://github.com/neovim/nvim-lspc-- https://github.com/neovim/nvim-lspconfig

local M = {}

function M.setup()
    require("mason").setup({
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
    })

    require("mason-lspconfig").setup({
        ensure_installed = {
            "rust_analyzer",
            "lua_ls",
            -- ts_ls intentionally omitted: typescript-tools.nvim replaces it
            "pyright",
            "jsonls",
            "yamlls",
            "gopls",
            "eslint",
            "sqlls",
        },

        -- automatic_installation removed (deprecated in mason-lspconfig v2)
        -- automatic_enable replaces it for the new vim.lsp API
        automatic_enable = true,
    })

    -- Get capabilities from cmp-nvim-lsp (set globally for all servers)
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Global defaults: apply capabilities and on_attach to ALL servers
    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    -- Move on_attach logic to the LspAttach autocmd (the new idiomatic pattern)
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(event)
            local bufnr = event.buf
            local client = vim.lsp.get_client_by_id(event.data.client_id)

            -- Fix: use vim.bo instead of deprecated nvim_buf_set_option
            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

            local opts = { noremap = true, silent = true, buffer = bufnr }
            local keymap = vim.keymap.set

            -- Navigation
            keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
            keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
            keymap(
                "n",
                "gi",
                vim.lsp.buf.implementation,
                vim.tbl_extend("force", opts, { desc = "Go to implementation" })
            )
            keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "List references" }))
            keymap(
                "n",
                "<leader>D",
                vim.lsp.buf.type_definition,
                vim.tbl_extend("force", opts, { desc = "Go to type definition" })
            )

            -- Documentation (removed native K here — lspsaga hover_doc is set in lsp_saga_keymaps.lua)
            keymap(
                "n",
                "<C-k>",
                vim.lsp.buf.signature_help,
                vim.tbl_extend("force", opts, { desc = "Show signature information" })
            )

            -- Workspace management
            keymap(
                "n",
                "<leader>wa",
                vim.lsp.buf.add_workspace_folder,
                vim.tbl_extend("force", opts, { desc = "Add workspace folder" })
            )
            keymap(
                "n",
                "<leader>wr",
                vim.lsp.buf.remove_workspace_folder,
                vim.tbl_extend("force", opts, { desc = "Remove workspace folder" })
            )
            keymap("n", "<leader>wl", function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))

            -- Code actions and refactoring
            keymap("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))

            -- Formatting
            keymap("n", "<leader>fr", function()
                vim.lsp.buf.format({ async = true })
            end, vim.tbl_extend("force", opts, { desc = "Format document" }))

            -- Diagnostics
            keymap(
                "n",
                "[d",
                vim.diagnostic.goto_prev,
                vim.tbl_extend("force", opts, { desc = "Go to previous diagnostic" })
            )
            keymap(
                "n",
                "]d",
                vim.diagnostic.goto_next,
                vim.tbl_extend("force", opts, { desc = "Go to next diagnostic" })
            )
            keymap(
                "n",
                "<leader>dl",
                vim.diagnostic.open_float,
                vim.tbl_extend("force", opts, { desc = "Show line diagnostics" })
            )
            keymap(
                "n",
                "<leader>dq",
                vim.diagnostic.setloclist,
                vim.tbl_extend("force", opts, { desc = "Add diagnostics to location list" })
            )

            if client then
                -- Enable inlay hints if the server supports them (Neovim 0.10+)
                if client.supports_method and client:supports_method("textDocument/inlayHint") then
                    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
                end
                print(string.format("LSP %s attached to buffer %d", client.name, bufnr))
            end
        end,
    })

    -- Toggle inlay hints
    vim.keymap.set("n", "<leader>ih", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
        vim.notify("Inlay hints: " .. (not enabled and "ON" or "OFF"), vim.log.levels.INFO)
    end, { desc = "Toggle inlay hints (buffer)" })

    -- Per-server config using the new vim.lsp.config API
    vim.lsp.config("gopls", {
        settings = {
            gopls = {
                analyses = { unusedparams = true },
                staticcheck = true,
                gofumpt = true,
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
            },
        },
    })

    vim.lsp.config("rust_analyzer", {
        settings = {
            ["rust-analyzer"] = {
                cargo = { allFeatures = true },
                checkOnSave = { command = "clippy" },
            },
        },
    })

    -- lua_ls: minimal config. lazydev.nvim handles workspace.library and the
    -- vim.* globals dynamically when editing Neovim config files.
    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                telemetry = { enable = false },
                hint = { enable = true },
            },
        },
    })

    -- ts_ls is replaced by typescript-tools.nvim (lua/plugins/typescript_tools.lua)

    vim.lsp.config("pyright", {
        settings = {
            python = {
                analysis = { typeCheckingMode = "basic" },
            },
        },
    })

    -- JSON: SchemaStore catalog (package.json, tsconfig.json, eslintrc, etc.)
    vim.lsp.config("jsonls", {
        settings = {
            json = {
                schemas = require("schemastore").json.schemas(),
                validate = { enable = true },
            },
        },
    })

    vim.lsp.config("sqlls", {
        settings = {
            sqlLanguageServer = {
                lint = { rules = {} },
            },
        },
    })

    -- YAML: SchemaStore covers SAM, CloudFormation, serverless.yml,
    -- buildspec.yml, GitHub Actions, k8s, OpenAPI, etc. Custom overrides
    -- are merged on top.
    vim.lsp.config("yamlls", {
        settings = {
            yaml = {
                keyOrdering = false,
                schemaStore = {
                    -- Disable built-in schemastore — we feed it via SchemaStore.nvim
                    enable = false,
                    url = "",
                },
                schemas = require("schemastore").yaml.schemas({
                    extra = {
                        {
                            name = "AWS SAM template (project local)",
                            url = "https://raw.githubusercontent.com/aws/serverless-application-model/main/samtranslator/schema/schema.json",
                            fileMatch = { "template.yaml", "template.yml" },
                        },
                    },
                }),
            },
        },
    })

    -- cfn-lsp-extra: completion + hover for AWS::* resource properties.
    -- Activated on YAML/JSON CloudFormation/SAM templates.
    vim.lsp.config("cfn_lsp_extra", {
        filetypes = { "yaml", "json" },
        root_markers = { "template.yaml", "template.yml", "samconfig.toml", ".git" },
    })

    -- Enable all servers (mason-lspconfig's automatic_enable handles this too,
    -- but being explicit here is fine and overrides nothing)
    vim.lsp.enable({
        "gopls",
        "rust_analyzer",
        "lua_ls",
        "pyright",
        "jsonls",
        "yamlls",
        "eslint",
        "sqlls",
    })


    -- Diagnostic display config (unchanged)
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

    -- Diagnostic signs
    local signs = { Error = "󰅚", Warn = "󰀪", Hint = "󰌶", Info = "" }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
end

return M
