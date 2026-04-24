-- https://github.com/ThePrimeagen/harpoon (branch: harpoon2)
-- Per-project pinned-files list. Faster than fuzzy-finding for the 3-5 files
-- you bounce between (handlers, template.yaml, tests).

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
            },
        })
    end,
}
