--VimLeavePre

--ref
--https://github.com/tamton-aquib/stuff.nvim/blob/main/lua/calc.lua

--TODO
--vim.keymap.set("i", "<C-,>", function()
--    vim.ui.input(
--        { prompt = "Calculator: " },
--        function(input)
--            local calc = load("return " .. (input or ""))()
--            if (calc) then
--                vim.api.nvim_feedkeys(tostring(calc), "i", true)
--            end
--        end
--    )
--end)
