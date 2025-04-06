
-- cmd aliases
--------------------------

local aliases = 
{
    cwd2f = "WorkDirToCurrent",
}

for alias, value in pairs(aliases) do
   vim.cmd("cnoreabbrev " .. alias .. " " .. value)
end
