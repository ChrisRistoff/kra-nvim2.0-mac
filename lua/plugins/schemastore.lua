-- https://github.com/b0o/SchemaStore.nvim
-- Bundled JSON / YAML schema catalog (CloudFormation, SAM, serverless.yml,
-- buildspec.yml, GitHub Actions, package.json, tsconfig.json, eslintrc, ...).
--
-- This plugin only ships the schemas; they are wired into yamlls and jsonls
-- inside lua/plugins/lsp_config.lua via require("schemastore").yaml.schemas()
-- and require("schemastore").json.schemas().

return {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- always use latest schemas
}
