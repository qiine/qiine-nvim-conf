return
{ 
    "norcalli/nvim-colorizer.lua",
    --enabled = true,
    cond = function()
      return vim.fn.getenv("COLORTERM") == "truecolor" 
    end,

    config = function()
        require("colorizer").setup()
    end
}

--#ff6347
--#000000
