
vim.lsp.config('luals', {
    cmd = {'lua-language-server'},
    filetypes = {'lua'},
    root_markers = {'.luarc.json', '.luarc.jsonc', ".git"},
    on_attach = function()
        print('luals is now active in this file')
    end,
})

--vim.lsp.enable('luals')
