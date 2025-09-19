std = "lua54"

-- Globals provided by Neovim
globals = {
  "vim",
}

-- Stylua enforces line width; disable luacheck length warn
max_line_length = false

unused_args = false -- allow unused args if prefixed with _
allow_defined = true
codes = true
