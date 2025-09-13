-- layout.lua (or inline in init.lua)
local M = {}

-- Tunables
local TARGET = 92 -- desired text width per pane
local SEP = 1 -- split column separator cost
local HIDDEN = 1 -- width for "overflow" panes (winminwidth must allow this)
local MAX_DESIRED = 5 -- "ideally 4-5" -> try 5 first
local ALT_DESIRED = 5 -- next best if 5 can't fit
local MIN_VISIBLE = 1 -- allow shrinking to a single visible pane if needed

local function can_fit(visible, desired, columns)
  -- Total = visible*TARGET + (desired-visible)*HIDDEN + (desired-1)*SEP
  return (visible * TARGET) + ((desired - visible) * HIDDEN) + ((desired - 1) * SEP) <= columns
end

local function relayout()
  -- Keep your current buffer, just rebuild the window layout in this tab
  vim.o.equalalways = false
  vim.o.winminwidth = HIDDEN

  local columns = vim.o.columns
  local current_buf = vim.api.nvim_get_current_buf()

  -- Decide desired total windows (prefer 5, else 4, else as many as makes sense >= MIN_VISIBLE)
  local desired = MAX_DESIRED
  if not can_fit(desired, desired, columns) then
    desired = ALT_DESIRED
  end
  if not can_fit(math.max(MIN_VISIBLE, math.min(desired, 3)), desired, columns) then
    -- If even 4 at 92 is too wide, still keep 'desired' to ALT_DESIRED so we can
    -- overflow most to HIDDEN; visible count will be reduced below.
    -- Cap desired so we don't open more splits than our max preference.
    desired = math.min(desired, MAX_DESIRED)
  end

  -- Find the largest visible count that fits given 'desired'
  local visible = math.min(desired, MAX_DESIRED)
  while visible > MIN_VISIBLE and not can_fit(visible, desired, columns) do
    visible = visible - 1
  end
  if not can_fit(visible, desired, columns) then
    -- Absolute last resort
    desired = visible
  end

  -- Rebuild layout cleanly in this tabpage
  vim.cmd 'only'
  
  -- Create additional splits with new empty buffers
  for i = 2, desired do
    vim.cmd 'vnew'
  end

  -- Move to leftmost window and ensure it has the original buffer
  vim.cmd 'wincmd t'
  vim.api.nvim_set_current_buf(current_buf)

  -- Apply widths left→right
  for i = 1, desired do
    local w = (i <= visible) and TARGET or HIDDEN
    vim.cmd('vertical resize ' .. w)
    if i < desired then
      vim.cmd 'wincmd l'
    end
  end
  
  -- Return to leftmost window
  vim.cmd 'wincmd t'
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
