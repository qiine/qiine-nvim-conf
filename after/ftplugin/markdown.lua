
-- [.md]
----------------------------------------------------------------------
local lsnip = require("luasnip")


vim.opt_local.spell = true


-- [Gutter]
vim.opt_local.signcolumn = "no"

-- Numbers
vim.opt_local.number = false

-- folds
vim.opt_local.foldcolumn = "1"
vim.opt_local.foldenable = true

-- vim.o.foldexpr = "v:lua.MarkdownFoldExpr()"

-- Fold function
function _G.MarkdownFoldExpr()
    local line = vim.fn.getline(vim.v.lnum)

    if line:match("^%s*$") then -- Ignore empty lines
        return vim.v.foldlevel
    end

    local heading = line:match("^(#+)%s")  -- Heading fold: level = number of # characters
    if heading then
        return #heading
    end

    -- List item fold: level based on indentation
    local list_item = line:match("^%s*[%*%-]%s")
    if list_item then
        local indent = line:match("^(%s*)") or ""
        -- 2 spaces per level
        local level = math.floor(#indent / 2) + 1
        return level
    end

    -- Other lines inherit previous fold level
    return vim.v.foldlevel
end


-- [Format]
vim.opt.formatoptions:append("a") -- auto reformat paragraphs while typing
vim.opt.formatoptions:append("t") -- auto-wrap text at textwidth
vim.opt.formatoptions:append("n") -- Recognize numbered lists (1., 2., etc.) and format them properly.

--Tab
vim.opt_local.shiftwidth  = 2 --Number of spaces to use for indentation
vim.opt_local.tabstop     = 2
vim.opt_local.softtabstop = 2 --Number of spaces to use for pressing TAB in insert mode


-- [Keymaps]
vim.keymap.set({"i","n","v"}, "<C-S-n>h", function()
    lsnip.try_insert_snippet("heading")
end)

vim.keymap.set({"i","n","v"}, "<C-S-n>cb", function()
    lsnip.try_insert_snippet("codeblock")
end)

vim.keymap.set({"i","n","v"}, "<C-S-n>tb", function()
    lsnip.try_insert_snippet("pipetable")
end)

-- Insert task
vim.keymap.set({"i","n","v"}, "<C-S-n>t", function()
    lsnip.try_insert_snippet("task")
end)

