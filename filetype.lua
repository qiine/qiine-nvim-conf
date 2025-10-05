
vim.filetype.add {
    pattern = {
        ['.*'] = function(path, bufnr)
            if path and vim.fn.getfsize(path) > 1024 * 1024 then
                vim.b[bufnr].is_bigfile = true
            end

            return nil
        end,
    },
}

