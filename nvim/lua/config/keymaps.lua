-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")
local map = vim.keymap.set

map({ "i", "n" }, "<esc>", "<esc>", { noremap = true, desc = "Escape" })

local Term = require('toggleterm.terminal').Terminal
local term_obj = Term:new()

map({"n", "i", "v"}, "<C-n>", "<cmd>nohl<cr>", { desc = "Clear highlights" })
map({"n", "i", "v"}, "<C-m>", function() require("notify").dismiss() end, { desc = "Dismiss notifications" })

local quickrun = function()
    vim.api.nvim_command("write")
    local filename = vim.fn.expand("%:t")
    local tmpout = '/tmp/lua_execute_tmp_out'
    local tmperr = '/tmp/lua_execute_tmp_err'
    command = "quickrun -p " .. filename
    local exitcode = os.execute(command .. ' > ' .. tmpout .. ' 2> ' .. tmperr)
    local stdout_file = io.open(tmpout)
    local stdout = stdout_file:read("*all")
    stdout_file.close()
    local no_color_stdout = string.gsub(stdout, '\027%[[0-9;]*m', '')
    require("notify").dismiss()

    if (exitcode == 256) then
        require("notify")("Compilation Error", "error", { title = filename })
    elseif (exitcode == 512) then
        require("notify")("Runtime Error", "error", { title = filename })
    elseif (exitcode == 0) then
        require("notify")(no_color_stdout, nil, { title = filename, timeout = 20000 })
    else
        require("notify")("Unknown Error", "error", { title = filename })
    end
end

map({"n"}, "<leader>r", quickrun, { desc = "Quickrun" })
map({"n", "v"}, "-", "^", { desc = "Go to first non-blank character of line" })

local toggleTerm = function()
    if term_obj:is_open() then
        term_obj:close()
    else
        term_obj:open()
    end
end
map({"n", "i", "v", "t"}, "<S-Tab>", toggleTerm, { desc = "Toggle terminal" })

map({"n", "i", "v"}, "<A-;>", function() local line = vim.api.nvim_get_current_line() vim.api.nvim_set_current_line(line .. ";") end, { desc = "Append semicolon" })
map({"n", "i", "v"}, "<A-,>", function() local line = vim.api.nvim_get_current_line() vim.api.nvim_set_current_line(line .. ",") end, { desc = "Append comma" })
map("i", "<A-[>", "<Esc>$A {}<Left>", { desc = "Append bracket" })
map("n", "<A-[>", "$A {}<Left>", { desc = "Append bracket" })

map("n", "<leader>W", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("viw", true, true, true), "n", true)
    vim.schedule(function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gsa", true, true, true), "v", true) end)
end, { desc = "Select word and append char" })

-- local savedFilename = ""
local compAndRunCur = function()
    vim.cmd('write')
    local filename = vim.fn.expand("%:t")
    -- savedFilename = filename
    if term_obj:is_open() then
        term_obj:send("quickrun " .. filename)
    else
        term_obj:open()
        term_obj:send("quickrun " .. filename)
    end
end
local compAndRunOther = function()
    local previous_id = vim.fn.bufnr('#')
    local filename = vim.api.nvim_buf_get_name(1)
    -- if (savedFilename == "") then
    --     return
    -- end
    -- local filename = savedFilename
    if term_obj:is_open() then
        term_obj:send("quickrun " .. filename)
    else
        term_obj:open()
        term_obj:send("quickrun " .. filename)
    end
end
map({"n", "i", "v"}, "<C-`>", compAndRunCur)
map("t", "<C-`>", compAndRunOther)
-- map({"n"}, "<leader>r", compAndRunCur, { desc = "Compile and run" })
-- map("t", "<leader>i", compAndRunOther, { desc = "Compile and run" })

local moveBufferRight = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd('wincmd h')
    vim.cmd('bprevious')
    vim.cmd("wincmd l")
end

local moveBufferLeft = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd('wincmd h')
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd('wincmd l')
    vim.cmd('close')
end

local moveBufferUp = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd('wincmd k')
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd('wincmd j')
    vim.cmd('close')
end

local moveBufferDown = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd('wincmd k')
    vim.cmd('bnext')
    vim.cmd("wincmd j")
end

map("n", "<A-Left>", moveBufferLeft, { noremap = true })
map("n", "<A-Right>", moveBufferRight, { noremap = true })
map("n", "<A-Up>", moveBufferUp, { noremap = true })
map("n", "<A-Down>", moveBufferDown, { noremap = true })

map({"n", "i", "v"}, "<C-S-Left>", "<cmd>BufferLineMovePrev<cr>")
map({"n", "i", "v"}, "<C-S-Right>", "<cmd>BufferLineMoveNext<cr>")
map({"n", "i", "v"}, "<S-Left>", "<cmd>BufferLineCyclePrev<cr>")
map({"n", "i", "v"}, "<S-Right>", "<cmd>BufferLineCycleNext<cr>")

map('n', '<A-1>', function() require("bufferline").go_to_buffer(1, true) end, { silent = true })
map('n', '<A-2>', function() require("bufferline").go_to_buffer(2, true) end, { silent = true })
map('n', '<A-3>', function() require("bufferline").go_to_buffer(3, true) end, { silent = true })
map('n', '<A-4>', function() require("bufferline").go_to_buffer(4, true) end, { silent = true })
map('n', '<A-5>', function() require("bufferline").go_to_buffer(5, true) end, { silent = true })
map('n', '<A-6>', function() require("bufferline").go_to_buffer(6, true) end, { silent = true })
map('n', '<A-7>', function() require("bufferline").go_to_buffer(7, true) end, { silent = true })
map('n', '<A-8>', function() require("bufferline").go_to_buffer(8, true) end, { silent = true })
map('n', '<A-9>', function() require("bufferline").go_to_buffer(9, true) end, { silent = true })
map('n', '<A-0>', function() require("bufferline").go_to_buffer(10, true) end, { silent = true })

map({"n", "i", "v"}, "<C-S-Up>", "<cmd>MultipleCursorsAddUp<CR>")
map({"n", "i", "v"}, "<C-S-Down>", "<cmd>MultipleCursorsAddDown<CR>")
map({"n", "i", "v"}, "<C-LeftMouse>", "<cmd>MultipleCursorsMouseAddDelete<CR>")
-- map({"n", "i", "v"}, "<leader>ps", "<cmd>MultipleCursorsAddBySearch<CR>")

map("v", "<C-/>", function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gcgv", true, true, true), "v", true) end, {noremap = true, silent = true})
map("n", "<C-/>", function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gcc", true, true, true), "v", true) end, {noremap = true, silent = true})

-- map({"n", "i"}, "<C-[>", "<cmd><<CR>")
-- map({"n", "i"}, "<C-]>", "<cmd>><CR>")
-- map("v", "<C-]>", "<cmd>'<,'>><CR>")

map("n", "_", "<cmd><lt><CR>", { silent = true, desc = "Outdent" })
map("n", "+", "<cmd>><CR>", { silent = true, desc = "Indent" })
map("v", "_", "<lt>gv", { silent = true, desc = "Outdent" })
map("v", "+", ">gv", { silent = true, desc = "Indent" })

function DelMarksOnCurrentLine()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    for char = 65, 90 do
        local mark = vim.fn.getpos("'" .. string.char(char))
        if mark[2] == current_line then
            vim.cmd("delmarks " .. string.char(char))
        end
    end
    for char = 97, 122 do
        local mark = vim.fn.getpos("'" .. string.char(char))
        if mark[2] == current_line then
            vim.cmd("delmarks " .. string.char(char))
        end
    end
end

map("n", "<leader>mc", "<cmd>delmarks a-zA-Z0-9<CR>", { noremap = true, silent = true, desc = "Delete all marks" })
map("n", "<leader>mf", DelMarksOnCurrentLine, { noremap = true, silent = true, desc = "Delete all marks" })

for char = 65, 90 do
    local ch = string.char(char)
    map("n", "`" .. ch, "<cmd>mark " .. ch .. "<CR>", { noremap = true, silent = true, desc = "add mark" .. ch })
    map("n", "m" .. ch, "`" .. ch, { noremap = true, silent = true, desc = "goto mark" .. ch })
end
for char = 97, 122 do
    local ch = string.char(char)
    map("n", "`" .. ch, "<cmd>mark " .. ch .. "<CR>", { noremap = true, silent = true, desc = "add mark" .. ch })
    map("n", "m" .. ch, "`" .. ch, { noremap = true, silent = true, desc = "goto mark" .. ch })
end

function debugProcess()
    local dap = require("dap")
    local filename = vim.fn.expand("%:t")
    local basename = vim.fn.expand("%:t:r")
    local tail = "--file \"" .. filename .. "\" --args=\"-ggdb3 -O0\""
    local notmatch = os.execute("codemd5 -c " .. tail .. " > /dev/null 2> /dev/null")
    if (notmatch ~= 0) then
        local exitcode = os.execute("g++ -o " .. basename .. " " .. filename .. " -ggdb3 -O0 > /dev/null 2> /dev/null")
        if (exitcode ~= 0) then
            require("notify")("Copmile Error", "error", { title = filename })
            return
        end
        -- require("notify")("Success", nil, { title = filename .. " -ggdb3 -O0" })
        os.execute("codemd5 -w " .. tail)
    end
    local line = vim.api.nvim_buf_get_lines(0, 1, 2, false)[1]
    line = line:gsub(".*run:%s*", "")
    line = line:gsub("^%s*(.-)%s*$", "%1")
    line = line:gsub("^%S+%s*", "")

    function parseLine(line)
        local args = {}
        local input, output, error

        for arg in line:gmatch("%S+") do
            if arg == "<" then
                input = line:match("<%s*(%S+)")
                line = line:gsub("<%s*%S+", "")
            elseif arg == ">" then
                output = line:match(">%s*(%S+)")
                line = line:gsub(">%s*%S+", "")
            elseif arg == "2>" then
                error = line:match("2>%s*(%S+)")
                line = line:gsub("2>%s*%S+", "")
            else
                table.insert(args, arg)
            end
        end

        return {
            args = args,
            input = input,
            output = output,
            error = error
        }
    end

    dap.adapters.cp = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "codelldb",
            args = {
                "--port",
                "${port}",
            },
        }
    }
    local parsed = parseLine(line)
    local config = {
        type = "cp",
        request = "launch",
        name = "cp",
        program = basename,
        cwd = '${workspaceFolder}',
        stdio = {parsed.input, parsed.output, parsed.error},
        args = parsed.args,
    }
    dap.run(config)
end
map("n", "<leader>dm", debugProcess, {desc = "CP debug"})