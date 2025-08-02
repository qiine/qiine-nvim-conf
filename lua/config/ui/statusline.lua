----------------
-- Statusline --
----------------

local mode_alias = {
    ['no']='O',['nov']='O-v',['noV']='O-Line',['no\22']='O-Block',
    ['n']='N',['niI']='Ni',['niR']='N',['niV']='N',['nt']='N',['ntT']='N',
    ['v']='V',['vs']='Vs',['V']='V-LINE',['Vs']='V-LINE',['\22']='V-BLOCK',['\22s']='V-BLOCK',
    ['s']='S',['S']='S-LINE',['\19']='S-BLOCK',
    ['i']='I',['ic']='Ic',['ix']='Ix',
    ['r']='r',['R']='R',['Rc']='Rc',['Rx']='Rx',['Rv']='V-R',['Rvc']='V-R',['Rvx']='V-R',
    ['c']='CMD',['cv']='EX',['ce']='EX',
    ['rm']='MORE',['r?']='CONFIRM',
    ['!']='SHELL',['t']='TERMINAL'
}


local function get_mode()
    local mode = vim.fn.mode()
    return mode_alias[mode] or mode
end



local function file_name()
    local file_path = vim.api.nvim_buf_get_name(0)

    --local file_name = vim.fn.expand("%:t")
    local file_name = vim.fn.fnamemodify(file_path, ":t")

    --local file_type = "." .. vim.bo.filetype
    --local file_type = "." .. vim.fn.expand("%:e")
    --if file_type == "." then file_type = "[.notype]" end

    --file properties
    local file_ondisk   = vim.fn.filereadable(file_path) == 1
    local file_readonly = vim.bo.readonly
    local file_exec     = vim.fn.executable(file_path) == 1

    if file_name == "" then file_name = "[noname]" end

    local file_ondisk_symbol = ""
    if file_ondisk then
        file_ondisk_symbol = ""
    else
        file_ondisk_symbol = '[nofile]'
    end

    local file_readonly_icon = "🔒"
    if not file_readonly then file_readonly_icon = "" end

    local file_exec_icon = "▶"
    if not file_exec then file_exec_icon = "" end

    return file_readonly_icon..file_exec_icon..file_name..file_ondisk_symbol
end

local function get_position()
    return string.format("%3d:%-2d", vim.fn.line("."), vim.fn.col("."))
end

local function line_count()
    local lines = vim.api.nvim_buf_line_count(0)
    return lines..'L'
end


local function render()
    return table.concat({
        " ",
        get_mode(),
        " ",

        "%=", --middle split

        get_position(),
        " ",
        line_count(),
        " ",
        file_name(),
    })
end

vim.opt.statusline = "%!v:lua.require('config.ui.statusline').render()"

return { render = render }


