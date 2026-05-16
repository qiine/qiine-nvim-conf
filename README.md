
# About
---
Probably **overcomplicated**   
Certainly   **not finished**    
Definitively  **heretical** 

My config revolves around Neovim as both an omni-editor and a tool orchestrator. 
It also serves as a learning platform and testbed for endless ideas.             
                                                                                
Why Neovim?
My text editor journey went as follows:  
`Code::Blocks → Notepad++ → Visual Studio → VSCode → Neovim`
I was aware of vim/nvim but it always felt intimidating. 
Then I switched to Linux and figured It was finally time to try it out!  
I hesitated a bit between Neovim and Emacs, but lua and the motions intrigued me...  

---
## Features
---
### ✏️Editing
  ---
- Hundreds of custom keymaps (I am unable to stop myself ;p)  
- Extensive mouse support! (°)°) with mouse binds! 
- Native Word "speed dial" in normal mode with `+` / `-`  
- Easy toggling of booleans: `true/false`, `Yes/No`, `on/off`, etc..
- Capitalization flipping  
- Auto-pairing via **nvim-autopairs**  
- Custom Text surround module, smartly detect words or surround selection (no motions though)
- Completion via **blink.cmp**, with extensive config including cmdline completion
- Built-in auto save with a timer every 7min

---
## Advanced nav
---
* Fast move using modifier + arrows
* Go to middle of screen and first/last line, using key-chords (heresy!)
* Nav dir using keymaps without file browser

---
### 🧠 Text intel
---
**Supported languages**:
`lua`, `markdown`, `yaml`, `bash`, `json`, `js`, `ts`, `nix`

* Treesitter highlighting  
* LSP (**nvim-lspconfig**) with per-language tweaks (lua_ls, marksman, bashls)       
* **nvim-lint**, 
* **conform.nvim** for formatting                    
* **live-rename**
* Snippets via luasnip and a lot of custom snippets 

---
### 📂 Filesystem
---
- **neo-tree**  
- **oil**  
- custom file system actions, commands, keymaps:
  - Delete current file with a shortcut, 
  - Set readonly
  - Move dir
  - And more

  ---
### 🛠 Task Runner                                                               
---
- **overseer.nvim** for build/run task management                                
- Custom templates: run buffer, run Neovim Lua, run project, run selection       

---                                                                              
### 🔀 Version Control                                                           
---                                                                              
- Custom Git thin wrapper with commands and keymaps                              
- **neogit** for Git operations                                                  
- **gitsigns** 

---
### 🗂 My org mode
---
A personal org system built into the editor:                                     
                                                                                
- **Notes**     — Create, explore, and manage markdown notes with templates and simple git integration                                                                        
- **Journal**   — Daily journal entries 
- **Plan**      — Task planning and simple overview UI                                          
- **Favorites** — Bookmarked files and watchlist                                 

---
### 🤖 AI Integration                                                            
---
Still very early and experimental                                                                       

- **CodeCompanion** for AI-assisted coding                                       
- AI invocation helpers

---
### 🖼 UI
---
* Neat dashboard with alpha-nvim, with randomized ASCII art splash, system info, and quick actions keys
* **lualine** with **many** custom components  
* **barbar.nvim** for tabs  
* Custom winbar, displaying current file path
* Customized statuscolumn with statuscol-nvim and some tweaking  
* **trouble.nvim**  
* **indent-blankline.nvim** for indentation guides
* **render-markdown.nvim** for live Markdown preview
* Custom quickfix setup, with keybinds and helper functions

---
### 💾 Session Management
---
- Auto save global Session on `VimLeavePre`  
- Command to save/edit session.vim file  
- Reload session with a custom command

Currently only supports **one global session**

---
### 🎨 Theme
---
- Based on **Nightfox**  
- Custom highlight groups  
- Tweaked for a **black & white eInk monitor** -- no proper colors for now

---
### 📦 Plugin Management
---
* Managed via **lazy.nvim**

---
## 🚀 Installation
---
### 🐧Linux 
---
* Backup existing config files if applicable.  
  ```sh
  mv ~/.config/nvim ~/.config/nvim_bak
  ```    
* Clone the repo:  
  ```sh
  git -C ~/.config/nvim/ clone git@github.com:qiine/qiine-nvim-conf.git .
  ```
* Open Neovim  
  ```sh
  nvim  
  ```
* Plugins will install automatically thanks to lazy.nvim  

---
### 🧪 Requirements
---
* neovim 0.11 (0.12 would be nicer) 

* Terminal  
  I chose wezterm, 
  config: [github.com/qiine/wezterm-conf](https://github.com/qiine/wezterm-conf)

  As neovim is a terminal centered application and I use a very complex set of keybinds. 
  A terminal supporting kitty keyboard reporting protocol or similar is a must.

  I have not spent any time making my nvim config usable 
  with other terminals and don't plan to. (I know Konsole struggles)

* git, ripgrep, fd, fzf

---
#### Optional
---
- **Lua**: `stylua`, `lua_ls`, `luacheck`                                        
- **Markdown**: `marksman`                                                       
- **Shell**: `bashls`                                                            
- **JavaScript/TypeScript**: `eslint_d`                                          

---
## 📜 License
---
This project is licensed under the MIT License.


