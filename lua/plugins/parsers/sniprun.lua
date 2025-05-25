return
{
    "michaelb/sniprun",
    branch = "master",

    build = "sh install.sh",

    config = function()
        require("sniprun").setup({
            display = {
                "Classic"
            }
        })

        vim.api.nvim_create_user_command("SnipRunInsertRes", function()
            local sa = require("sniprun.api")

            local row = vim.api.nvim_win_get_cursor(0)[1]
            local vanchor_row, vhead_row, result_row

            --smartly wrapping results into comment, so we can call sniprun multiple times easily
            local prefixes = {
                lua = "---> ",
                c = "//-> ",
                cpp = "//-> ",
                rust = "//-> ",
                javascript = "//-> ",
                typescript = "//-> ",
                python = "#-> ",
                sh = "#-> "
            }

            --get visual selection range (0-based)
            vanchor_row = vim.fn.line("v")
            vhead_row = vim.fn.line(".")

            result_row = vhead_row

            if vanchor_row > vhead_row then
                result_row = vhead_row - 1
                vanchor_row, vhead_row = vhead_row, vanchor_row
            end

            local called = false
            sa.register_listener(function(result)
                if called then return end
                called = true

                if result.status ~= "ok" then
                    print("SnipRun error: " .. result.message)
                    return
                end

                local lines = vim.split(result.message, "\n", { plain = true })

                local ft = vim.bo.filetype
                local prefix = prefixes[ft] or "-> "

                if #lines > 0 then
                    lines[1] = prefix .. lines[1]
                end

                --Write result to buf
                if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
                    vim.api.nvim_buf_set_lines(0, result_row, result_row, false, lines)
                else
                    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
                end
            end)

            --Snip
            if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
                sa.run_range(vanchor_row, vhead_row, nil, { display = { "Api" } })
            else
                sa.run_range(1, row, nil, { display = { "Api" } })
            end
        end, {})

    end--config
}

