-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")
local map = vim.keymap.set

map({ "i", "n" }, "<esc>", "<esc>", { noremap = true, desc = "Escape" })

map({ "n", "i", "v" }, "<C-n>", "<cmd>nohl<cr>", { desc = "Clear highlights" })
map({ "n", "i", "v" }, "<C-m>", function()
    require("notify").dismiss()
end, { desc = "Dismiss notifications" })

local quickrun = function()
    if vim.api.nvim_buf_get_option(0, "modified") then
        vim.cmd("write")
    end

    local filename = vim.fn.expand("%:t")
    local tmpout = "/tmp/lua_execute_tmp_out"
    os.execute("rm -f " .. tmpout)
    local command = "quickrun -p " .. filename
    local exitcode = os.execute(command .. " >> " .. tmpout .. " 2>&1")
    local output_file = io.open(tmpout)
    if not output_file then
        require("notify")("Unknown Error", "error", { title = filename })
        return
    end
    local output = output_file:read("*a")
    output_file:close()
    local no_color_stdout = string.gsub(output, "\027%[[0-9;]*m", "")
    require("notify").dismiss()

    if exitcode == 256 then
        require("notify")("Compilation Error", "error", { title = filename })
    elseif exitcode == 512 then
        require("notify")("Runtime Error", "error", { title = filename })
    elseif exitcode == 0 then
        require("notify")(no_color_stdout, nil, { title = filename, timeout = 20000 })
    else
        require("notify")("Unknown Error", "error", { title = filename })
    end
end
map({ "n" }, "<leader>r", quickrun, { desc = "Quickrun" })
map({ "n", "v" }, "-", "^", { desc = "Go to first non-blank character of line" })

local changeTodoToDone = function()
    local line = vim.api.nvim_get_current_line()
    local todoIndex = string.find(line, "TODO:")
    local fixIndex = string.find(line, "FIX:")
    local noteIndex = string.find(line, "NOTE:")
    local hackIndex = string.find(line, "HACK:")
    if todoIndex then
        line = string.sub(line, 1, todoIndex - 1) .. "DONE: " .. string.sub(line, todoIndex + 5)
        vim.api.nvim_set_current_line(line)
    elseif fixIndex then
        line = string.sub(line, 1, fixIndex - 1) .. "DONE: " .. string.sub(line, fixIndex + 4)
        vim.api.nvim_set_current_line(line)
    elseif noteIndex then
        line = string.sub(line, 1, noteIndex - 1) .. "DONE: " .. string.sub(line, noteIndex + 5)
        vim.api.nvim_set_current_line(line)
    elseif hackIndex then
        line = string.sub(line, 1, hackIndex - 1) .. "DONE: " .. string.sub(line, hackIndex + 5)
        vim.api.nvim_set_current_line(line)
    end
end

map({ "n", "i", "v" }, "<A-;>", function()
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(line .. ";")
end, { desc = "Append semicolon" })
map({ "n", "i", "v" }, "<A-,>", function()
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(line .. ",")
end, { desc = "Append comma" })
map("n", "<leader>dd", changeTodoToDone, { desc = "change TODO to DONE" })
map("i", "<A-Enter>", "<Esc>$A {}<Left><CR><Esc>O", { desc = "Append bracket" })
map("n", "<A-Enter>", "$A {}<Left>CR><Esc>O", { desc = "Append bracket" })
map("i", "<A-a>", "<Esc>A", { desc = "Append bracket" })
map("n", "<A-a>", "A", { desc = "Append bracket" })

map("n", "<leader>W", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("viw", true, true, true), "n", true)
    vim.schedule(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gsa", true, true, true), "v", true)
    end)
end, { desc = "Select word and append char" })

local run_command = function(command)
    local handle = io.popen(command, "r")
    local output
    if handle then
        output = handle:read("*a")
        handle:close()
    else
        output = "error"
    end
    return output
end

local compAndRun = function()
    if vim.api.nvim_buf_get_option(0, "modified") then
        vim.cmd("write")
    end

    local buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local match_compile = buffer_content:match("comp%s-:=(.-)\n")
    if (match_compile == nil) then
        match_compile = ""
    end
    match_compile = match_compile:gsub("^%s*(.-)%s*$", "%1")
    local match_run = buffer_content:match("run%s-:=(.-)\n")
    if (match_run == nil) then
        match_run = ""
    end
    match_run = match_run:gsub("^%s*(.-)%s*$", "%1")
    local match_wid = buffer_content:match("wid%s-:=(.-)\n")
    if (match_wid == nil) then
        match_wid = ""
    end
    match_wid = match_wid:gsub("^%s*(.-)%s*$", "%1")
    local match_dir = buffer_content:match("dir%s-:=(.-)\n")
    if (match_dir == nil) then
        match_dir = ""
    end
    match_dir = match_dir:gsub("^%s*(.-)%s*$", "%1")

    local kitten_cmd = "kitty @ ls | jq '.[] | .tabs[] | select(.is_focused == true) | .layout, (.windows | length)'"

    local layout, num
    local output = run_command(kitten_cmd)
    layout, num = output:match('"(.-)"\n(%d+)')
    num = tonumber(num)

    local command = ""
    if match_compile ~= "" and match_run ~= "" then
        command = match_compile .. " && " .. match_run
    else
        command = match_run
    end
    if command == "" then
        require("notify")("no command", "error")
        return
    end

    local cwd = ""
    if match_dir ~= "" then
        if string.sub(match_dir, 1, 1) == "/" or match_dir:match("^%a:") ~= nil then
            cwd = match_dir
        else
            local path_sep = package.config:sub(1, 1)
            cwd = table.concat({ vim.fn.expand("%:p:h"), match_dir }, path_sep)
        end
        cwd = run_command("realpath " .. cwd)
    end

    local fp, err = io.open("/home/jyh/.cache/quickrun/last-command", "w")
    if not fp then
        require("notify")("open file error: " .. tostring(err), "error")
        return
    end
    local record_cwd = cwd
    if record_cwd == "" then
        record_cwd = vim.fn.expand("%:p:h")
    end
    fp:write(command, "\n", record_cwd, "\n")
    fp:close()

    if layout == "stack" then
        os.execute("kitty @ last-used-layout")
    end
    local match_window = "--match recent:1"
    if match_wid ~= "" then
        match_window = "--match id:" .. match_wid
    end
    if num == 1 and match_wid == "" then
        local current_id = os.getenv("KITTY_WINDOW_ID")
        if cwd == "" then
            os.execute("kitten @ launch --cwd=last_reported")
        else
            os.execute("kitten @ launch --cwd=" .. cwd)
        end
        os.execute("kitten @ focus-window --match id:" .. current_id)
    else
        if cwd ~= "" then
            local window_cwd = run_command("kitten @ ls " .. match_window .. " | jq '.[0].tabs[0].windows[0].cwd' | cut -d \'\"\' -f 2")
            if (window_cwd ~= cwd) then
                os.execute("kitten @ send-text " .. match_window .. " \"cd " .. cwd .. "\n\"")
            end
        end
    end
    -- os.execute("kitten @ action " .. match_window ..  " clear_terminal scroll active")
    os.execute("kitty @ send-text " .. match_window .. " \"" .. command .. '\n"')
end

map({ "n", "i", "v" }, "<C-`>", compAndRun)

local moveBufferRight = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd("wincmd h")
    vim.cmd("bprevious")
    vim.cmd("wincmd l")
end

local moveBufferLeft = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd("wincmd h")
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd("wincmd l")
    vim.cmd("close")
end

local moveBufferUp = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd("wincmd k")
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd("wincmd j")
    vim.cmd("close")
end

local moveBufferDown = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    vim.cmd("split")
    vim.api.nvim_win_set_buf(0, current_buffer)
    vim.cmd("wincmd k")
    vim.cmd("bnext")
    vim.cmd("wincmd j")
end

map("n", "<A-Left>", moveBufferLeft, { noremap = true })
map("n", "<A-Right>", moveBufferRight, { noremap = true })
map("n", "<A-Up>", moveBufferUp, { noremap = true })
map("n", "<A-Down>", moveBufferDown, { noremap = true })

map({ "n", "i", "v" }, "<S-Left>", "<cmd>BufferLineMovePrev<cr>")
map({ "n", "i", "v" }, "<S-Right>", "<cmd>BufferLineMoveNext<cr>")
-- map({ "n", "i", "v" }, "<S-Left>", "<cmd>BufferLineCyclePrev<cr>")
-- map({ "n", "i", "v" }, "<S-Right>", "<cmd>BufferLineCycleNext<cr>")

map("n", "<A-1>", function()
    require("bufferline").go_to_buffer(1, true)
end, { silent = true })
map("n", "<A-2>", function()
    require("bufferline").go_to_buffer(2, true)
end, { silent = true })
map("n", "<A-3>", function()
    require("bufferline").go_to_buffer(3, true)
end, { silent = true })
map("n", "<A-4>", function()
    require("bufferline").go_to_buffer(4, true)
end, { silent = true })
map("n", "<A-5>", function()
    require("bufferline").go_to_buffer(5, true)
end, { silent = true })
map("n", "<A-6>", function()
    require("bufferline").go_to_buffer(6, true)
end, { silent = true })
map("n", "<A-7>", function()
    require("bufferline").go_to_buffer(7, true)
end, { silent = true })
map("n", "<A-8>", function()
    require("bufferline").go_to_buffer(8, true)
end, { silent = true })
map("n", "<A-9>", function()
    require("bufferline").go_to_buffer(9, true)
end, { silent = true })
map("n", "<A-0>", function()
    require("bufferline").go_to_buffer(10, true)
end, { silent = true })

map({ "n", "i", "v" }, "<C-S-PageUp>", "<cmd>MultipleCursorsAddUp<CR>")
map({ "n", "i", "v" }, "<C-S-PageDown>", "<cmd>MultipleCursorsAddDown<CR>")
map({ "n", "i", "v" }, "<C-LeftMouse>", "<cmd>MultipleCursorsMouseAddDelete<CR>")
-- map({"n", "i", "v"}, "<leader>ps", "<cmd>MultipleCursorsAddBySearch<CR>")

map("v", "<C-/>", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gcgv", true, true, true), "v", true)
end, { noremap = true, silent = true })
map("n", "<C-/>", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gcc", true, true, true), "v", true)
end, { noremap = true, silent = true })

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

map("n", "<leader>m1", "<cmd>delmarks a-zA-Z0-9<CR>", { noremap = true, silent = true, desc = "Delete all marks" })
map("n", "<leader>m2", DelMarksOnCurrentLine, { noremap = true, silent = true, desc = "Delete all marks" })

for char = 65, 90 do
    local ch = string.char(char)
    map(
        "n",
        "<leader>m" .. ch,
        "<cmd>mark " .. ch .. "<CR>",
        { noremap = true, silent = true, desc = "add mark " .. ch }
    )
    map("n", "m" .. ch, "`" .. ch, { noremap = true, silent = true, desc = "goto mark " .. ch })
end
for char = 97, 122 do
    local ch = string.char(char)
    map(
        "n",
        "<leader>m" .. ch,
        "<cmd>mark " .. ch .. "<CR>",
        { noremap = true, silent = true, desc = "add mark " .. ch }
    )
    map("n", "m" .. ch, "`" .. ch, { noremap = true, silent = true, desc = "goto mark " .. ch })
end

local debugProcess = function()
    local dap = require("dap")
    local filename = vim.fn.expand("%:t")
    local basename = vim.fn.expand("%:t:r")
    local tail = '--file "' .. filename .. '" --args="-ggdb3 -O0"'
    local notmatch = os.execute("codemd5 -c " .. tail .. " > /dev/null 2> /dev/null")
    if notmatch ~= 0 then
        local exitcode = os.execute("g++ -o " .. basename .. " " .. filename .. " -ggdb3 -O0 > /dev/null 2> /dev/null")
        if exitcode ~= 0 then
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

    local parseLine = function(cur_line)
        local args = {}
        local input, output, error

        for arg in cur_line:gmatch("%S+") do
            if arg == "<" then
                input = cur_line:match("<%s*(%S+)")
                cur_line = cur_line:gsub("<%s*%S+", "")
            elseif arg == ">" then
                output = cur_line:match(">%s*(%S+)")
                cur_line = cur_line:gsub(">%s*%S+", "")
            elseif arg == "2>" then
                error = cur_line:match("2>%s*(%S+)")
                cur_line = cur_line:gsub("2>%s*%S+", "")
            else
                table.insert(args, arg)
            end
        end

        return {
            args = args,
            input = input,
            output = output,
            error = error,
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
        },
    }
    local parsed = parseLine(line)
    local config = {
        type = "cp",
        request = "launch",
        name = "cp",
        program = basename,
        cwd = "${workspaceFolder}",
        stdio = { parsed.input, parsed.output, parsed.error },
        args = parsed.args,
    }
    dap.run(config)
end
map("n", "<leader>dm", debugProcess, { desc = "CP debug" })

map("n", "<leader>uu", function()
    require("telescope").extensions.undo.undo()
end)
map("n", "<leader>1", function()
    vim.cmd("write")
end)

map("n", "<leader>aw", "/\\<\\><Left><Left>", { noremap = true, silent = true })
map("v", "<C-x>", '"0d', { noremap = true })
map("v", "<C-c>", '"0y', { noremap = true })

local function ctrlv()
    local register = "0"
    local content = vim.fn.getreg(register)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = cursor_pos[1]
    local col = cursor_pos[2]
    vim.api.nvim_buf_set_text(0, line - 1, col, line - 1, col, { content })
    local new_col = col + #content
    vim.api.nvim_win_set_cursor(0, { line, new_col })
end
map("i", "<C-v>", ctrlv, { noremap = true })
map({ "n", "v" }, "<C-v>", '"0p', { noremap = true })

map("i", "<C-a>", "<Esc>A", { noremap = true })
map("n", "<C-a>", "A", { noremap = true })

map("n", "<A-c>", "<cmd>CopilotChatInPlace<CR>", { desc = "Open chat" })

-- kitty and vim integration

map("n", "<f2>", "<cmd>ZenMode<CR>", { desc = "ZenMode" })
map("n", "<leader>pmd", "<cmd>MarkdownPreview<CR>", { desc = "Markdown Preview" })
map("n", "<leader>pms", "<cmd>MarkdownPreviewStop<CR>", { desc = "Markdown Preview" })

-- map("n", "<C-j>", ":KittyNavigateDown<CR>", { noremap = true, silent = true })
-- map("n", "<C-k>", ":KittyNavigateUp<CR>", { noremap = true, silent = true })
-- map("n", "<C-l>", ":KittyNavigateRight<CR>", { noremap = true, silent = true })
-- map("n", "<C-h>", ":KittyNavigateLeft<CR>", { noremap = true, silent = true })

-- resizing splits
-- amount defaults to 3 if not specified
-- use absolute values, no + or -
-- the functions also check for a range,
-- so for example if you bind `<A-h>` to `resize_left`,
-- then `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
vim.keymap.set("n", "<A-S-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-S-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-S-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-S-l>", require("smart-splits").resize_right)
-- moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
-- vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)
-- swapping buffers between windows
vim.keymap.set("n", "<C-Left>", require("smart-splits").swap_buf_left)
vim.keymap.set("n", "<C-Down>", require("smart-splits").swap_buf_down)
vim.keymap.set("n", "<C-Up>", require("smart-splits").swap_buf_up)
vim.keymap.set("n", "<C-Right>", require("smart-splits").swap_buf_right)
