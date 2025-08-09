
--lazy plugins management

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

--lazy.nvim setup
require("lazy").setup({

    spec = {
        --import/override with your plugins
        --sadly no recursive search in "plugins"
       { import = "plugins" },
       { import = "plugins.parsers" },
       { import = "plugins.editing" },
       { import = "plugins.ui" },
       { import = "plugins.ui.editor" },
       { import = "plugins.ui.themes" },
  },

    defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot of plugins that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
    },

    change_detection = {
        enabled = true, -- Make sure it's set to true
        notify = false,  -- Show notification when reloading
    },

    --lazy.nvim panel color scheme
    --install = { colorscheme = { "habamax" } },

    checker = {
        enabled = true, -- check for plugin updates periodically
        notify = false, -- notify on update
    },

    performance = {
        rtp = {
        -- disable some rtp plugins
        disabled_plugins = {
            "gzip",
            -- "matchit",
            -- "matchparen",
            -- "netrwPlugin",
            "tarPlugin",
            --"tohtml",
            --"tutor",
            "zipPlugin",
            },
        },
    },

})--end setup
