return
{
    "L3MON4D3/LuaSnip",
    lazy = false,

    dependencies = { "rafamadriz/friendly-snippets", lazy = true },

    config = function()
        require("luasnip").setup()
        local ls = require("luasnip")

        -- fetch user custom snips
        require('luasnip.loaders.from_vscode').lazy_load {
            paths = vim.fn.stdpath('config') .. '/snippets',
        }

        ---@param prefix string
        function ls.try_insert_snippet(prefix)
            local snips = ls.get_snippets(vim.bo.filetype)

            if not snips then return end

            for _, snip in ipairs(snips) do
                if snip.trigger == prefix then
                    ls.snip_expand(snip) return
                end
            end
        end



        -- keymaps
        vim.keymap.set({"i","n"}, "<C-S-e>", function() ls.expand() end, {silent = true})

        vim.keymap.set("s", "<Tab>",   function() ls.jump( 1) end, {silent = true})
        vim.keymap.set("s", "<S-Tab>", function() ls.jump(-1) end, {silent = true})

            -- vim.keymap.set({"i", "s"}, "<C-E>", function()
        --     if ls.choice_active() then
        --         ls.change_choice(1)
        --     end
        -- end, {silent = true})

    end
}



