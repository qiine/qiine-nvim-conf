return
{
  cmd = { "harper-ls", "--stdio" },
  root_markers = {
    ".git",
  },
  filetypes = {
    "gitcommit",
    "typst",
    "markdown",
    "txt",
    "org",
    "norg",
    "lua",
  },
}
