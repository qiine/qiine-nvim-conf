local v = vim

-------------------------------------------------------
--File--
-------------------------------------------------------
v.opt.title = true --display file title useful for tabs name

v.opt.confirm = true --Ask for save before quit



--[View]--------------------------------------------------
v.opt.laststatus = 3
--0 → Never show the statusline.
--1 → Show the statusline only when there are multiple windows.
--2 → Always show the statusline in every window.
--3 → (Global Statusline) A single statusline is displayed at the bottom, shared across all windows.



--[Edit]--------------------------------------------------
--Autocomplete
v.opt.completeopt = "menuone,noinsert,noselect"
--v.opt.completeopt = "menu,menuone,popup,fuzzy" -- modern completion menu
--menuone: always show completion menu even if there is only one match
--noinsert: prevents automatically inserting the first match when completion menu is shown
--noselect: ensures no item is selected by default when completion menu shown.
v.o.pumheight = 10 --max height of completion menu
vim.o.pumblend = 10 --Transparency for popup-menu

--[Context menu]--------------------------------------------------
--To create a new menu item, use the ":menu" commands.  They are mostly like
--the ":map" set of commands (see |map-modes|), but the first argument is a menu
--item name, given as a path of menus and submenus with a '.' between them,
--e.g.: >
--
--  :menu File.Save  :w<CR>
--  :inoremenu File.Save  <C-O>:w<CR>
--  :menu Edit.Big\ Changes.Delete\ All\ Spaces  :%s/[ ^I]//g<CR>
--v.api.nvim_create_autocmd("VimEnter", {
--    callback = function()
--        v.api.nvim_command [[aunmenu PopUp.How-to\ disable\ mouse]]
--        v.api.nvim_command [[amenu PopUp.References :lua vim.lsp.buf.references()<cr>]]
--        v.api.nvim_command [[vmenu PopUp.Format\ selected :FormatSelected<cr>]]
--    end,
--    desc = "contextual menu",
--})

local contextmenu_items =
{
    --"anoremenu PopUp.{}Goto\\ sdefinition "..[[<cmd>lua vim.lsp.buf.definition()<CR>]],
    "anoremenu PopUp.{}References "..[[<cmd>Trouble lsp_references toggle focus=true<CR>]],
    --"aunmenu PopUp.Inspect ",
    --"anoremenu PopUp.Format\\ selected  <cmd>lua Print('hellomenu')<CR>",
    "anoremenu PopUp.Format\\ selected "..[[<cmd>'<,'>FormatSelected<CR>]],
    "amenu     PopUp.-1- <NOP>",
    "anoremenu PopUp.Copy "..[["+y]],
    "anoremenu PopUp.Paste "..[["+p]],
    "anoremenu PopUp.Delete "..[["_d]],
    "amenu     PopUp.-2- <NOP>",
    "anoremenu PopUp.Telescope "..[[<cmd>Telescope<CR>]],
    "anoremenu PopUp.Open\\ in\\ browser "..[[gx]],
}

local group = vim.api.nvim_create_augroup("nvim_popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
    pattern = "*",
    group = group,
    desc = "Setup context menu",
    callback = function()
         --vim.cmd("aunmenu PopUp") --rem all base entries

        --Insert new menu entries
        for _, item in ipairs(contextmenu_items) do
            vim.cmd(item)
        end


        --Optional, smart enable/disable based on context
        --vim.cmd[[
        --    amenu disable PopUp.Open\ in\ browser",
        --]]
        --
        --if vim.lsp.get_clients({ bufnr = 0 })[1] then
        --    vim.cmd[[
        --        amenu enable PopUp.References
        --    ]]
        --end
        --
        --local urls = require("vim.ui")._get_urls()
        --if vim.startswith(urls[1], "http") then
        --    vim.cmd("amenu enable PopUp.Open\\ in\\ browser")
        --end
    end,
})


-------------------------------------------------------
-- Dashboard --
-------------------------------------------------------
--vim.api.nvim_create_autocmd("VimEnter", {
--command = "opendashboard"
--})


function Testfunction ()
    local sometable =    {
    "lol"
                    }

            end


