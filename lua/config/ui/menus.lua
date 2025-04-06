
local v = vim
 
-------------------------------------------------------
--File--
-------------------------------------------------------
v.opt.title = true --display file title useful for tabs name

v.opt.confirm = true --Ask for save before quit


-------------------------------------------------------
-- View -and [[amenu PopUp.Telescope\ <Cmd>Telesco-
-------------------------------------------------------
v.opt.laststatus = 3
--0 → Never show the statusline.
--1 → Show the statusline only when there are multiple windows.
--2 → Always show the statusline in every window.
--3 → (Global Statusline) A single statusline is displayed at the bottom, shared across all windows.


-------------------------------------------------------
-- Edit --
-------------------------------------------------------
--Autocomplete
v.opt.completeopt = "menuone,noinsert,noselect"
--v.opt.completeopt = "menu,menuone,popup,fuzzy" -- modern completion menu
--menuone: always show completion menu even if there is only one match
--noinsert: prevents automatically inserting the first match when completion menu is shown
--noselect: ensures no item is selected by default when completion menu shown.
v.o.pumheight = 10        --max height of completion menu
vim.o.pumblend = 10  --Transparency for popup-menu

-------------------------------------------------------
-- Context menu --
-------------------------------------------------------
--To create a new menu item, use the ":menu" commands.  They are mostly like
--the ":map" set of commands (see |map-modes|), but the first argument is a menu
--item name, given as a path of menus and submenus with a '.' between them,
--e.g.: >
--
--  :menu File.Save  :w<CR>
--  :inoremenu File.Save  <C-O>:w<CR>
--  :menu Edit.Big\ Changes.Delete\ All\ Spaces  :%s/[ ^I]//g<CR>
v.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        v.api.nvim_command [[aunmenu PopUp.How-to\ disable\ mouse]]
        v.api.nvim_command [[amenu PopUp.References :lua vim.lsp.buf.references()<cr>]]
        v.api.nvim_command [[amenu PopUp.Telescope :Telescope<CR>]]
        v.api.nvim_command [[vmenu PopUp.Format\ selected :FormatSelected<cr>]]
    end,
    desc = "contextual menu",
})

-------------------------------------------------------
-- Dashboard --
-------------------------------------------------------
--vim.api.nvim_create_autocmd("VimEnter", {
--command = "opendashboard"
--})


