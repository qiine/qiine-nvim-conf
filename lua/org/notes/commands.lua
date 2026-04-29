
-- # Notes

local fs  = require("fs")
local notes = require("org.notes")


vim.api.nvim_create_user_command("NoteExpore", notes.explore, {})




