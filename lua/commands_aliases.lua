
-- cmd aliases
--------------------------

local aliases =
{
    cwd2f = "WorkDirToCurrent",
    lsw = "Lsw",
}

for alias, value in pairs(aliases) do
   vim.cmd("cnoreabbrev " .. alias .. " " .. value)
end
