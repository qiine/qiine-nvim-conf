return {
    filetypes = { 'bash', 'sh' },
    root_markers = { '.git' },
    settings = {
        bashIde = {
            shellcheckArguments = {
                "-e", "SC2034", -- Hide "foo appears unused"  https://www.shellcheck.net/wiki/SC2034
                "-e", "SC1090",
                "-e", "SC1091",
            },
        },
    },
}
