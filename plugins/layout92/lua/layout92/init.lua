-- layout.lua (or inline in init.lua)
local M = {}

-- Tunables
local TARGET = 92 -- desired text width per pane
local SEP = 1 -- split column separator cost
local HIDDEN = 1 -- width for "overflow" panes (winminwidth must allow this)
local MAX_DESIRED = 5 -- "ideally 4-5" -> try 5 first
local ALT_DESIRED = 5 -- next best if 5 can't fit
local MIN_VISIBLE = 1 -- allow shrinking to a single visible pane if needed

local function calculate_optimal_layout(total_width)
  -- Calculate how many full-width windows can actually fit
  local available = total_width
  local max_full_windows = math.floor(available / (TARGET + SEP))

  -- Determine optimal window count based on what fits well
  local window_count, full_windows

  if max_full_windows >= 4 then
    -- Can fit 4+ full windows comfortably: create 5 total
    window_count = 5
    full_windows = 4
  elseif max_full_windows >= 3 then
    -- Can fit 3 full windows comfortably: create 4 total
    window_count = 4
    full_windows = 3
  elseif max_full_windows >= 2 then
    -- Can fit 2 full windows comfortably: create 3 total
    window_count = 3
    full_windows = 2
  elseif max_full_windows >= 1 then
    -- Can fit 1 full window: create 2 total
    window_count = 2
    full_windows = 1
  else
    -- Very narrow: single window
    window_count = 1
    full_windows = 1
  end

  -- Calculate actual remaining space
  local separators = (window_count - 1) * SEP
  local used_by_full = full_windows * TARGET
  local remaining_space = total_width - separators - used_by_full

  return {
    window_count = window_count,
    full_windows = full_windows,
    remaining_space = math.max(0, remaining_space),
  }
end

local function relayout()
  -- Work with Neovim's layout system instead of fighting it
  vim.o.equalalways = false
  vim.o.winminwidth = 0

local columns = vim.o.columns

-- Capture all visible window buffers before layout change
local windows = vim.api.nvim_list_wins()
local buffers = {}
for _, win in ipairs(windows) do
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
    table.insert(buffers, buf)
  end
end

local current_buf = vim.api.nvim_get_current_buf()
local current_buf_index = 1
for i, buf in ipairs(buffers) do
  if buf == current_buf then
    current_buf_index = i
    break
  end
end

  -- Calculate optimal layout for current width
  local layout = calculate_optimal_layout(columns)

  -- Rebuild layout cleanly
  vim.cmd 'only'

  -- Create optimal number of splits
  for i = 2, layout.window_count do
    vim.cmd 'vnew'
  end

-- Move to leftmost window and distribute saved buffers
vim.cmd 'wincmd t'

local windows_to_populate = math.min(#buffers, layout.window_count)
for i = 1, windows_to_populate do
  vim.api.nvim_set_current_buf(buffers[i])
  if i < layout.window_count then
    vim.cmd 'wincmd l'
  end
end

  -- Calculate target widths for all windows
  local target_widths = {}
  for i = 1, layout.window_count do
    if i <= layout.full_windows then
      target_widths[i] = TARGET -- 92 chars
    elseif i == layout.full_windows + 1 and layout.remaining_space > 0 then
      target_widths[i] = layout.remaining_space
    else
      target_widths[i] = 1 -- safety net
    end
  end

  -- Apply widths in REVERSE order (rightmost first) to prevent redistribution
  for i = layout.window_count, 1, -1 do
    -- Move to window i
    vim.cmd 'wincmd t' -- go to first window
    for j = 2, i do
      vim.cmd 'wincmd l' -- move right j-1 times
    end

    -- Set width and lock it immediately
    vim.cmd('vertical resize ' .. target_widths[i])
    vim.cmd 'setlocal winfixwidth'
  end

  -- Final enforcement pass - go through leftmost windows and ensure they have TARGET width
  vim.cmd 'wincmd t' -- start at leftmost
  for i = 1, math.min(layout.full_windows, layout.window_count) do
    local actual_width = vim.api.nvim_win_get_width(0)
    if actual_width ~= TARGET then
      -- Force correct width
      vim.cmd('vertical resize ' .. TARGET)
      vim.cmd 'setlocal winfixwidth'
    end
    if i < layout.window_count then
      vim.cmd 'wincmd l'
    end
  end

-- Return to the window with the originally focused buffer
vim.cmd 'wincmd t'
if current_buf_index > 1 and current_buf_index <= layout.window_count then
  for j = 2, current_buf_index do
    vim.cmd 'wincmd l'
  end
end
end

function M.setup()
  -- Run once and on any terminal/GUI resize
  vim.api.nvim_create_autocmd({ 'VimEnter', 'VimResized' }, {
    callback = relayout,
    desc = 'Auto-layout 92-col vertical splits with overflow hidden',
  })

  -- :Layout92 command to re-run manually
  vim.api.nvim_create_user_command('Layout92', relayout, {})
end

return M
