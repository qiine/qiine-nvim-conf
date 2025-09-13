
Surely     **overcomplicated**  
Absolutely **not finished**  
Extremely  **heretical** ;p

I was aware of vim/nvim for years, after switching to linux I figured It was  
finally time to try it out.  
At first I hesitated between nvim and emacs, but lua and the motions intrigued me...  
I am still in the "hjkl? hu no? arrow's fine" phase though, haha.  

My text editor journey:  
`Code::Blocks → Notepad++ → Visual Studio → VSCode → Neovim`


## Features
---
### ✏️Editing
---
- Hundreds of custom keymaps (I am unable to stop myself ;p)  
- Extensive mouse support! (°)°) with mouse binds! 
- Native Word "speed dial" in normal mode with `+` / `-`  
- with Easy toggling of booleans: `true/false`, `yes/no`, `on/off`  
- and Capitalization flipping  
- Auto-pairing via **nvim-autopairs**  
- Built-in white spaces trimming on save (+custom command)  
- Completion via **blink.cmp**, with extensive config including cmdline 
  completion
- Built-in auto save with a timer every 7min


### 🧠 Text intelligence
---
**Supported languages**:
- lua  
- markdown  
- yaml  
- toml
- bash

**Tools**:
- Treesitter highlighting  
- LSP  
- Custom snippets  
- **nvim-lint**, 
- **conform.nvim**  
* sniprun  


### 📂 File Management
---
- **neo-tree**  
- **oil.nvim**  
- custom user commands and keymaps, delete current file, set readonly, move dir etc...


### 🖼 UI
---
- **lualine** with **many** custom components  
- **barbar.nvim** for tabs  
- custom winbar, displaying curr file path
* customized statuscolumn thanks to gitsign, statuscol-nvim and some 
  tweaking  
- **trouble.nvim**  

- **indent-blankline.nvim**


### 💾 Session Management
---
Tiny helpers:
- Auto save on `VimLeavePre`  
- Command to save/edit session  
- Reload session with a custom command

Currently only supports **one global session**


### 🎨 Theme
---
- Based on **Nightfox**  
- Custom highlight groups  
- Tweaked for a **black & white eInk monitor** -- no proper colors for now


### 📦 Plugin Management
---
- Managed via **lazy.nvim**


## Installation
---
Install latest neovim version with your package manager of choice.  
Backup your existing config files if any.  
Clone the repo:  
```sh
git clone https://github.com/qiine/qiine-nvim-conf.git
```
Open Neovim.  
```sh
nvim  
```
plugins will install automatically thanks to lazy.nvim  


### 🧪 Requirements
* fzf
* fd
* ripgrep

optional
- stylua
- marksman
- lua_ls
- luacheck
- eslint_d



---

- Tested with latest **Neovim**  
- Using **WezTerm**, config: [github.com/qiine/wezterm-conf](https://github.com/qiine/wezterm-conf)

