--Zalgo-style "cursed" text is essentially diacritic spam it takes normal
--characters and stacks tons of combining Unicode marks (diacritics) above,
--below, and through them. These marks are meant to be subtle (like accents or
--tildes), but when you pile on 10–30+ per letter, it creates that
--glitched/distorted effect.

--Example:

--Normal A

--With combining marks: A̴̡̛͖̜̬̬̳̥̔̓͋̈́͝͝

--You're not "abusing" in the illegal sense — just misusing the original intent
--of the characters. Most systems display them fine, but some terminals, fonts,
--or UI elements may break or look misaligned because of how extreme the
--stacking is.

--you can write a Zalgo input mode in Neovim by intercepting keys and adding
--combining diacritics as you type. It’s cursed, but fun.

--Here’s how you could approach it:
--🔧 Basic Concept
--Intercept normal keypresses.
--Add combining diacritic marks (randomly or with a pattern).
--Insert the glitched character into the buffer.
--Toggle this mode with a command or keybinding.

--🧠 Diacritic Pool

--Here's a minimal pool you can use for starters (Zalgo uses these ranges):

--local zalgo_above = {
--    "\u{0300}", "\u{0301}", "\u{0302}", "\u{0303}", "\u{0304}", "\u{0305}",
--    "\u{0306}", "\u{0307}", "\u{0308}", "\u{0309}", "\u{030A}", "\u{030B}"
--}

--🧪 Demo Function: Zalgo-fy a char

--local function zalgo_char(char, amount)
--    local zalgo_above = {
--        "\u{0300}", "\u{0301}", "\u{0302}", "\u{0303}", "\u{0304}", "\u{0305}",
--        "\u{0306}", "\u{0307}", "\u{0308}", "\u{0309}", "\u{030A}", "\u{030B}"
--    }

--    for _ = 1, amount or 3 do
--        char = char .. zalgo_above[math.random(#zalgo_above)]
--    end

--    return char
--end

--🔁 Example Usage

--You could hook into InsertCharPre or override input via a mapping:

--vim.keymap.set("i", "<F2>", function()
--    local char = vim.fn.nr2char(vim.fn.getchar())
--    local cursed = zalgo_char(char)
--    vim.api.nvim_put({ cursed }, 'c', true, true)
--end)

--Now pressing <F2> in insert mode followed by a key will insert a cursed version of that key.
--🧙 Cursed Mode (Conceptual)

--You could expand this into a full "Cursed Mode" like:

--local cursed_mode = false

--vim.api.nvim_create_user_command("CursedMode", function()
--    cursed_mode = not cursed_mode
--    print("Cursed mode: " .. tostring(cursed_mode))
--end, {})

---- then override input when cursed_mode == true (in mappings or through feeding keys)
