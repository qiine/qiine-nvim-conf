-- ~/.config/nvim/plugin/pi.lua

local pi_job = nil
local pi_output = {}
local pi_callbacks = {}

-- Start pi as a subprocess for THIS Neovim instance
local function start_pi()
    if pi_job and vim.fn.jobwait({pi_job}, 0)[1] == -1 then
        -- Job still running
        return pi_job
    end

    pi_job = vim.fn.jobstart(
        { 'pi', '--mode', 'rpc' },
        {
            on_stdout = function(jobid, data, event)
                for _, line in ipairs(data) do
                    if line ~= "" then
                        local ok, response = pcall(vim.json.decode, line)
                        if ok then
                            handle_response(response)
                        end
                    end
                end
            end,
            on_stderr = function(jobid, data, event)
                vim.notify("Pi error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
            end,
            on_exit = function(jobid, exit_code, event)
                vim.notify("Pi exited with code " .. exit_code, vim.log.levels.WARN)
                pi_job = nil
            end,
        }
    )

    return pi_job
end

-- Send a message to pi (THIS Neovim's instance)
local function send_to_pi(message)
    local job = start_pi()
    if not job then
        vim.notify("Failed to start pi", vim.log.levels.ERROR)
        return
    end

    local json_str = vim.json.encode(message)
    vim.fn.jobsend(job, json_str .. "\n")
end

-- Handle responses
local function handle_response(response)
    if response.type == "agent_start" then
        vim.notify("🚀 Pi started processing...", vim.log.levels.INFO)

    elseif response.type == "message_update" then
        if response.assistantMessageEvent and response.assistantMessageEvent.type == "text_delta" then
            print("Pi: " .. response.assistantMessageEvent.delta)
        end

    elseif response.type == "agent_end" then
        vim.notify("✅ Pi finished!", vim.log.levels.INFO)

    elseif response.type == "tool_execution_end" then
        vim.notify("Tool: " .. response.toolName, vim.log.levels.INFO)
    end
end

-- Command: Ask pi to analyze current file
vim.api.nvim_create_user_command('PiAnalyze', function()
    local current_file = vim.fn.expand('%')
    local current_dir = vim.fn.getcwd()

    send_to_pi({
        type = "input",
        text = "Analyze the file: " .. current_file
    })
end, {})

-- Command: Ask pi something
vim.api.nvim_create_user_command('PiAsk', function(opts)
    if opts.args == "" then
        vim.notify("Usage: :PiAsk <question>", vim.log.levels.WARN)
        return
    end

    send_to_pi({
        type = "input",
        text = opts.args
    })
end, { nargs = '*' })

-- Keybindings
vim.keymap.set('n', '<leader>pa', ':PiAnalyze<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>p?', ':PiAsk ', { noremap = true }) -- Opens command line

-- Cleanup on exit
vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
        if pi_job then
            vim.fn.jobstop(pi_job)
        end
    end
})


