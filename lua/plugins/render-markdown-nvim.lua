return
{
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons

    config = function()
        require('render-markdown').setup({
            render_modes = { "i", 'n', 'v', 'c', 't' },
            --preset = "obsidian",
            heading = {
                --icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                icons = { '•]', '•]=', '•]--', '•]---', '•]----', '•]-----' },
                width = "block"
            },
            code = {
                width = "block"
            }
        })
    end
}
