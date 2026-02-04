
# About
---
Probably **overcomplicated**   
Certainly   **not finished**    
Definitively  **heretical** ;p  

This config revolve around nvim as both an omni editor and a tool orchestrator. 
It is also very much a test bed for new ideas!  

Why nvim?
My text editor journey went as follow:  
`Code::Blocks → Notepad++ → Visual Studio → VSCode → Neovim`
I was aware of vim/nvim for years but didn't think much of it, 
Then I switching to Linux and figured It was finally time to try it out!  
I hesitated a bit between nvim and emacs, but lua and the motions intrigued me...  


## ✨ Features
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

### Advance nav
---
fast move using modifier + arrows
go to middle of screen go to first/last line
nav dir using keymaps without file browser

### 🧠 Text intel
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
- **nvim-lint**, 
- **conform.nvim**  
* sniprun  

- Custom snippets  

### 📂 Version control
---
neogit
custom git thin wrapper


### 📂 File Management
---
- **neo-tree**  
- **oil**  
- custom file system actions, cmds, keymaps:
  - delete current file with a shortcut, 
  - set readonly,
  - move dir
  - etc...


### 🖼 UI
---
- **lualine** with **many** custom components  
- **barbar.nvim** for tabs  
- custom winbar, displaying current file path
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
- Based on **Lightfox**  
- Custom highlight groups  
- Tweaked for a **black & white eInk monitor** -- no proper colors for now


### 📦 Plugin Management
---
- Managed via **lazy.nvim**


## 🚀 Installation
---
### 🐧Linux 
* Install neovim (at least 0.11) with your package manager of choice.  

* Backup existing config files if applicable.  
    ```sh
    mv ~/.config/nvim ~/.config/nvim_bak
    ```    
* cd to config files location
  ```sh
  cd ~/.config/nvim/
  ```
* Clone the repo:  
  ```sh
  git clone git@github.com:qiine/qiine-nvim-conf.git
  ```
* Open Neovim  
  ```sh
  nvim  
  ```
* Plugins will install automatically thanks to lazy.nvim  


### 🧪 Requirements
* Terminal  
  I choose wezterm, 
  config: [github.com/qiine/wezterm-conf](https://github.com/qiine/wezterm-conf)

  As neovim is a terminal centered application and I use a very complex sets of keybinds. 
  A terminal supporting kitty keyboard reporting protocol or similar is a must.

  I have not spent any time making my nvim config usable 
  with other terminals and don't plan to. (I know Konsole struggles)

* git
* ripgrep
* fd
* fzf

optional
- stylua
- marksman
- lua_ls
- luacheck
- eslint_d


## 📜 License
---
This project is licensed under the MIT License.


