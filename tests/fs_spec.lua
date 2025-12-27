
local utils = require("fs").utils

-- test
-- leave last element alone be it filename or last subpath
-- handle trail slash even if dir does not exsit on disc
-- test
local tests = {
    {
    --     input = "/home/qm/Personal/dotfiles/User/nvim/lua/commands.lua",
    --     expected = "/home/qm/Per..../dot..../User/nvim/lua/commands.lua",
    -- },
    -- {
    --     input = "home/qm/Personal/dotfiles/User/nvim/lua/commands.lua",
    --     expected = "home/qm/Per..../dot..../User/nvim/lua/commands.lua",
    -- },
    -- {
    --     input = "home/qm/Personal/dotfiles/User/nvim/markdown/",
    --     expected = "home/qm/Per..../dot..../User/nvim/mamarkdownr/",
    -- },
    -- {
    --     input = "home/qm/Personal/dotfiles/User/nvim/markdown/",
    --     expected = "home/qm/Per..../dot..../User/nvim/markdown/",
    -- },
    -- {
    --     input = "home/qm/Personal/dotfiles/User/nvim/markdown",
    --     expected = "home/qm/Per..../dot..../User/nvim/mar..../markdown",
    },
}

local function run_tests()
    local passed = 0
    for i, test in ipairs(tests) do
        local result = utils.path_compress(test.input)
        assert(
            result == test.expected,
            string.format("Test %d failed: %s -> %s (expected %s)", i, test.input, result, test.expected)
        )
        passed = passed + 1
    end
    print(string.format("All %d tests passed!", passed))
end

run_tests()

