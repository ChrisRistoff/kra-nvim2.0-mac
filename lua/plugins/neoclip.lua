return {
    {
        "AckslD/nvim-neoclip.lua",
        requires = {
            -- { 'kkharji/sqlite.lua', module = 'sqlite' },
            -- you'll need at least one of these
            {'nvim-telescope/telescope.nvim'},
            -- {'ibhagwan/fzf-lua'},
        },
        config = function()
            require('neoclip').setup()
        end,
    }
}
