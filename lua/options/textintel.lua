----------------------------------------------------------------------
-- # [Text intel] --
----------------------------------------------------------------------
-- Define word delim
vim.o.iskeyword = "@,48-57,192-255,-,_"
-- @       -> alphabet,
-- 48-57   -> 0-9 numbers,
-- 192-255 -> extended Latin chars

-- vim.opt.keywordprg = "dict"

-- Detect binary files
-- vim.api.nvim_create_autocmd("BufReadPost", {
--     group = "UserAutoCmds",
--     callback = function(args)
--        local path = args.file
--        if path == "" then return end

--         local result = vim.system(
--             { "file", "--mime-type", "-b", path },
--             { text = true }
--         ):wait()
--         if result.code ~= 0 then return end

--         local mime = vim.trim(result.stdout or "")
--         if not mime:match("^text/") then
--             vim.cmd("%!xxd")
--         end
--     end,
-- })


vim.opt.makeprg = "make"



-- ## [ Bigfiles]
--------------------------------------------------------------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('BufRead', {
    group = 'UserAutoCmds',
    callback = function(args)
        if vim.b[args.buf].is_bigfile then
            vim.cmd("BigfileMode")
        end
    end,
})



-- ## [Spelling]
----------------------------------------------------------------------
vim.opt.spell = false
--TODO make it ignore fenced code in marksown
--maybe allow only for comment for other filetypes?

-- SpellIgnore rules
-- vim.api.nvim_create_autocmd("Syntax", {
--     group = vim.api.nvim_create_augroup("SpellIgnore", {clear=true}),
--     callback = function()
--         -- Make URL tokens spell-ignored
--         vim.cmd [[
--             syn match UrlNoSpell /http\S\+/ contains=@NoSpell containedin=@AllSpell transparent
--         ]]

--         -- Abbreviations in ALLCAPS (2+ letters/digits)
--         vim.cmd [[
--             syn match AbbrevNoSpell /\<[A-Z][A-Z0-9]\+\>/ contains=@NoSpell containedin=@AllSpell transparent
--         ]]
--     end,
-- })


vim.o.spellsuggest = "best,6"

vim.o.spellcapcheck = ""
-- Pattern to locate the end of a sentence.  The following word will be
-- checked to start with a capital letter.  If not then it is highlighted
-- with SpellCap |hl-SpellCap| (unless the word is also badly spelled).
-- When this check is not wanted make this option empty.
-- Only used when 'spell' is set.
-- Be careful with special characters, see |option-backslash| about
-- including spaces and backslashes.
-- To set this option automatically depending on the language, see
-- |set-spc-auto|.


-- ### [Language]
local preferedlangs = {
    "en",
    "fr"
}

vim.o.spelllang = "en,fr" --

-- TODO p3 make it use our own custom dico
vim.opt.spellfile = {
    vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
    vim.fn.stdpath("config") .. "/spell/fr.utf-8.add",
}

vim.api.nvim_create_user_command("PickCurrDocLang", function()
    local dictpath = vim.fn.stdpath("config").."/spell/"

    vim.ui.select(preferedlangs, {prompt = "Pick document language"},
    function(choice)
        if choice then
            vim.opt_local.spelllang = choice
            vim.opt_local.spellfile = dictpath..choice..".utf-8.add"
        end
    end)
end, {})

vim.api.nvim_create_user_command("PickDocsLang", function()
    local dictpath = vim.fn.stdpath("config").."/spell/"

    vim.ui.select(preferedlangs, {prompt = "Pick document language"},
    function(choice)
        if choice then
            vim.o.spelllang = choice
            vim.o.spellfile = dictpath..choice..".utf-8.add"
        end
    end)
end, {})




-- ## [LSP]
----------------------------------------------------------------------
vim.lsp.enable({
    "lua-ls",
    "ts-ls",
    "rust-analyzer",
    "marksman",
})






