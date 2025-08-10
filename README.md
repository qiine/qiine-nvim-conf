
# ✨ My Fancy Neovim Config ✨

Surely **overcomplicated**  
Absolutely **not finished**  
Extremely **heretical** ;p

My text editor journey:  
`Code::Blocks → Notepad++ → Visual Studio → VSCode → Neovim`

I was aware of vim/nvim for years, after switching to linux I figured It was 
finally time to try it out. 
At first I hesitated between nvim and emacs, but the motions intrigued me... 
I am still in the "hjkl? hu no? arrow's fine" phase though, haha. 


  ---
## ✏️Editing
---

- Hundreds of custom keymaps (I am unable to stop myself ;p)  
- Extensive mouse support! (°)°) with mouse binds! 
- Native Word "speed dial" in normal mode with `+` / `-`  
- with Easy toggling of booleans: `true/false`, `yes/no`, `on/off`  
- and Capitalization flipping  
- Auto-pairing via **nvim-autopairs**  
- Built-in Whitespace trimming on save (+custom command)  
- Completion via **blink.cmp**, with extensive config including cmdline 
  completion
- Built-in auto save with a timer every 7min


---
## 🧠 Text Parsing
---
**Supported languages**:
- Lua  
- Markdown  
- YAML  
- TOML
- bash

**Tools**:
- Treesitter highlighting  
- LSP  
- Custom snippets  
- **nvim-lint**, 
- **conform.nvim**  
- Spell checking


---
## 📂 File Management
---
- **neo-tree**  
- **oil.nvim**  
- **telescope.nvim**
- custom files user commands like delete current file, set readonly, move etc...


---
## 🖼 UI
---
- **lualine** with **many** custom components  
- **barbar.nvim** for tabs  
- **trouble.nvim**  
- **indent-blankline.nvim**


---
## 💾 Session Management
---
Tiny helpers:
- Auto save on `VimLeavePre`  
- Command to save/edit session  
- Reload session with a custom command

Currently only supports **one global session**


---
## 🎨 Theme
---
- Based on **Nightfox**  
- Custom highlight groups  
- Tweaked for a **black & white eInk monitor** — no colors for now


---
## 📦 Plugin Management
---
- Managed via **lazy.nvim**


---
## 🧪 Environment
---
### Dependencies
- stylua
- marksman
- lua_ls
- luacheck
- eslint_d
* fzf
* fd
* ripgrep

---

- Tested with latest **Neovim**  
- Using **WezTerm**, config: [github.com/qiine/wezterm-conf](https://github.com/qiine/wezterm-conf)

