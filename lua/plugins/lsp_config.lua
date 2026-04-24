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
            "pyright",
            "jsonls",
            "yamlls",
            "gopls",
            "eslint",
            "sqlls",
            "ts_ls",
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
                if client.supports_method and client:supports_method("textDocument/inlayHint") then
                    if not vim.b[bufnr].kra_inlay_hint_disabled then
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end
                end

                vim.notify(string.format("󰒋 %s attached", client.name), vim.log.levels.INFO, { title = "LSP" })
            end
        end,
    })

    -- Toggle inlay hints. Sets a buffer-local "user disabled" flag so the
    -- InsertEnter/InsertLeave autocmds below don't fight the user's choice.
    -- Wrapped in VimEnter so it runs *after* startup.nvim's dashboard, which
    -- otherwise claims `<leader>cs` for "Telescope colorscheme".
    local function toggle_inlay_hints()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
        vim.b.kra_inlay_hint_disabled = enabled and true or nil
        vim.notify("Inlay hints: " .. (not enabled and "ON" or "OFF"), vim.log.levels.INFO)
    end
    vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("KraInlayHintKeymap", { clear = true }),
        callback = function()
            vim.keymap.set("n", "<leader>cs", toggle_inlay_hints, { desc = "Toggle inlay hints (buffer)" })
        end,
    })


    -- Disable inlay hints in insert mode, re-enable on leaving it.
    -- This avoids the upstream "Invalid 'col': out of range" error from
    -- runtime/lua/vim/lsp/inlay_hint.lua when hints get out of sync with
    -- in-progress edits (Neovim issue #36318).
    local hint_aug = vim.api.nvim_create_augroup("KraInlayHintInsertToggle", { clear = true })
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = hint_aug,
        callback = function(args)
            if vim.bo[args.buf].buftype ~= "" then
                return
            end
            if vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }) then
                vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
            end
        end,
    })
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = hint_aug,
        callback = function(args)
            if vim.bo[args.buf].buftype ~= "" then
                return
            end
            if vim.b[args.buf].kra_inlay_hint_disabled then
                return
            end
            local clients = vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/inlayHint" })
            if #clients > 0 then
                vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
            end
        end,
    })

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

    -- ts_ls: TypeScript / JavaScript LSP (typescript-language-server wraps tsserver).
    --
    -- Inlay hints: typescript-language-server reads BOTH `init_options.preferences`
    -- (at startup) AND `settings.{typescript,javascript}.inlayHints` (via
    -- workspace/didChangeConfiguration). We pass both so hints render as soon as
    -- the server is ready instead of only after the first config push.
    vim.lsp.config("ts_ls", {
        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },
        init_options = {
            preferences = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
        },

        settings = {
            typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                    completeFunctionCalls = true,
                },
                inlayHints = {
                    parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = false },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
                },
            },
            javascript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                    completeFunctionCalls = true,
                },
                inlayHints = {
                    parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = false },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
                },
            },
        },
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
        "ts_ls",
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
