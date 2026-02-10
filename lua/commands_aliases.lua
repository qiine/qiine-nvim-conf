
-- cmd aliases
--------------------------

local aliases =
{
    lsw = "Lsw",
}

for alias, value in pairs(aliases) do
   vim.cmd("cnoreabbrev " .. alias .. " " .. value)
end
