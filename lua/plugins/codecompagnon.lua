
local opt = {
    interactions = {
        chat = {
            adapter = {
                name = "llama.cpp",
                model = "Qwen3.5-35B-A3B-UD-IQ4_NL",
            },
            opts = {
                -- completion_provider = "blink", -- blink|cmp|coc|default
                -- system_prompt = "",
            },
            roles = {
                ---The header name for the LLM's messages
                llm = function(adapter)
                    return "AI | " .. adapter.formatted_name
                end,
                ---The header name for your messages
                user = "User",
            },
            keymaps = {
                send = {
                    modes = {
                        i = { "<C-s>", "<C-S-CR>" },
                        n = { "<C-s>", "<C-S-CR>" },
                        v = { "<C-s>", "<C-S-CR>" },
                    },
                    callback = "keymaps.send",
                    opts = { noremap = true, silent = true },
                },
                change_adapter = {
                    modes = { i = "<S-Space>aa", n = "<S-Space>aa" },
                    -- callback = "keymaps.change_adapter",
                    description = "[Adapter] Change adapter and model",
                    opts = { noremap = true, silent = true },
                },
                close = { -- this disconect from llama.cpp and the ACP
                    modes = {
                        i = "<C-S-q>",
                        n = "<C-S-q>",
                        v = "<C-S-q>",
                    },
                    callback = "keymaps.close",
                },
            },
        },

        inline = {
            adapter = {
                name = "llama.cpp",
                model = "Qwen3.5-35B-A3B-UD-IQ4_NL",
            },
        },

        agent = {
            name = "opencode",
            model = "Qwen3.5-35B-A3B-UD-IQ4_NL",
        },

        background = {
            adapter = {
                name = "llama.cpp",
                model = "Qwen3.5-35B-A3B-UD-IQ4_NL",
            },
        },
    },

    adapters = {
        http = {
            ["llama.cpp"] = function()
                return require("codecompanion.adapters").extend(
                    "openai_compatible",
                    {
                        env = {
                            url = "http://127.0.0.1:8080", -- replace with your llama.cpp instance
                            api_key = "TERM",
                            chat_url = "/v1/chat/completions",
                        },
                        -- handlers = {
                        --     parse_message_meta = function(self, data)
                        --         local extra = data.extra
                        --         if extra and extra.reasoning_content then
                        --             data.output.reasoning = { content = extra.reasoning_content }
                        --             if data.output.content == "" then
                        --                 data.output.content = nil
                        --             end
                        --         end
                        --         return data
                        --     end,
                        -- },
                    }
                )
            end,
        },
    }, --adapters

    display = {
        action_palette = {
            width = 95,
            height = 10,
        },
        chat = {
            show_settings = false, -- Show the model settings in the chat buffer?
            show_token_count = true, -- Show the token count for the current chat in the buffer?
            start_in_insert_mode = true,
            show_header_separator = true,

            type = "buffer", -- float|buffer

            window = {
                buflisted = false, -- List the chat buffer in the buffer list?
                sticky = true, -- Chat window follows when switching tabs

                layout = "vertical", -- float|vertical|horizontal|tab|buffer
                full_height = false, -- for vertical layout
                position = right, -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)

                width = 0.5, ---@return number|fun(): number
                height = 0.8, ---@return number|fun(): number
                border = "single",
                relative = "editor",

                -- Ensure that long paragraphs of markdown are wrapped
                opts = {
                    foldcolumn = "0",
                    signcolumn = "no",
                    statuscolumn = "",
                    number = false,
                    breakindent = true,
                    linebreak = true,
                    wrap = true,
                },
            },
        },
    },
}

return {
    "olimorris/codecompanion.nvim",
    enabled = true,
    -- event = "VimEnter",

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },

    config = function()
        require("codecompanion").setup(opt)
    end,
}

-- keymaps = {
--     ["<C-s>"] = "keymaps.save", -- Save the chat buffer and trigger the LLM
--     ["<C-w>"] = "keymaps.close", -- Close the chat buffer
-- ["q"] = "keymaps.cancel_request", -- Cancel the currently streaming request
--     ["gc"] = "keymaps.clear", -- Clear the contents of the chat
--     ["ga"] = "keymaps.codeblock", -- Insert a codeblock into the chat
--     ["gs"] = "keymaps.save_chat", -- Save the current chat
--     ["gt"] = "keymaps.add_tool", -- Add a tool to the current chat buffer
--     ["]"] = "keymaps.next", -- Move to the next header in the chat
--     ["["] = "keymaps.previous", -- Move to the previous header in the chat
-- },
