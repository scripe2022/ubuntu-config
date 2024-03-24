-- HELPER FUNCTIONS
local parse

local escape_char_map = {
    ["\\"] = "\\",
    ['"'] = '"',
    ["\b"] = "b",
    ["\f"] = "f",
    ["\n"] = "n",
    ["\r"] = "r",
    ["\t"] = "t",
}

local escape_char_map_inv = { ["/"] = "/" }
for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
end

local function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
        res[select(i, ...)] = true
    end
    return res
end

local space_chars = create_set(" ", "\t", "\r", "\n")
local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals = create_set("true", "false", "null")

local literal_map = {
    ["true"] = true,
    ["false"] = false,
    ["null"] = nil,
}

local function next_char(str, idx, set, negate)
    for i = idx, #str do
        if set[str:sub(i, i)] ~= negate then
            return i
        end
    end
    return #str + 1
end

local function decode_error(str, idx, msg)
    local line_count = 1
    local col_count = 1
    for i = 1, idx - 1 do
        col_count = col_count + 1
        if str:sub(i, i) == "\n" then
            line_count = line_count + 1
            col_count = 1
        end
    end
    error(string.format("%s at line %d col %d", msg, line_count, col_count))
end

local function codepoint_to_utf8(n)
    -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
    local f = math.floor
    if n <= 0x7f then
        return string.char(n)
    elseif n <= 0x7ff then
        return string.char(f(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
        return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
        return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128, f(n % 4096 / 64) + 128, n % 64 + 128)
    end
    error(string.format("invalid unicode codepoint '%x'", n))
end

local function parse_unicode_escape(s)
    local n1 = tonumber(s:sub(1, 4), 16)
    local n2 = tonumber(s:sub(7, 10), 16)
    -- Surrogate pair?
    if n2 then
        return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
        return codepoint_to_utf8(n1)
    end
end

local function parse_string(str, i)
    local res = ""
    local j = i + 1
    local k = j

    while j <= #str do
        local x = str:byte(j)

        if x < 32 then
            decode_error(str, j, "control character in string")
        elseif x == 92 then -- `\`: Escape
            res = res .. str:sub(k, j - 1)
            j = j + 1
            local c = str:sub(j, j)
            if c == "u" then
                local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                    or str:match("^%x%x%x%x", j + 1)
                    or decode_error(str, j - 1, "invalid unicode escape in string")
                res = res .. parse_unicode_escape(hex)
                j = j + #hex
            else
                if not escape_chars[c] then
                    decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                end
                res = res .. escape_char_map_inv[c]
            end
            k = j + 1
        elseif x == 34 then -- `"`: End of string
            res = res .. str:sub(k, j - 1)
            return res, j + 1
        end

        j = j + 1
    end

    decode_error(str, i, "expected closing quote for string")
end

local function parse_number(str, i)
    local x = next_char(str, i, delim_chars)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
        decode_error(str, i, "invalid number '" .. s .. "'")
    end
    return n, x
end

local function parse_literal(str, i)
    local x = next_char(str, i, delim_chars)
    local word = str:sub(i, x - 1)
    if not literals[word] then
        decode_error(str, i, "invalid literal '" .. word .. "'")
    end
    return literal_map[word], x
end

local function parse_array(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
        local x
        i = next_char(str, i, space_chars, true)
        -- Empty / end of array?
        if str:sub(i, i) == "]" then
            i = i + 1
            break
        end
        -- Read token
        x, i = parse(str, i)
        res[n] = x
        n = n + 1
        -- Next token
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "]" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected ']' or ','")
        end
    end
    return res, i
end

local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = next_char(str, i, space_chars, true)
        -- Empty / end of object?
        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end
        -- Read key
        if str:sub(i, i) ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)
        -- Read ':' delimiter
        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, space_chars, true)
        -- Read value
        val, i = parse(str, i)
        -- Set
        res[key] = val
        -- Next token
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected '}' or ','")
        end
    end
    return res, i
end

local char_func_map = {
    ['"'] = parse_string,
    ["0"] = parse_number,
    ["1"] = parse_number,
    ["2"] = parse_number,
    ["3"] = parse_number,
    ["4"] = parse_number,
    ["5"] = parse_number,
    ["6"] = parse_number,
    ["7"] = parse_number,
    ["8"] = parse_number,
    ["9"] = parse_number,
    ["-"] = parse_number,
    ["t"] = parse_literal,
    ["f"] = parse_literal,
    ["n"] = parse_literal,
    ["["] = parse_array,
    ["{"] = parse_object,
}

parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = char_func_map[chr]
    if f then
        return f(str, idx)
    end
    decode_error(str, idx, "unexpected character '" .. chr .. "'")
end

local json_decode = function(str)
    if type(str) ~= "string" then
        error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, space_chars, true))
    idx = next_char(str, idx, space_chars, true)
    if idx <= #str then
        decode_error(str, idx, "trailing garbage")
    end
    return res
end
-- HELPER FUNCTIONS END

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
    -- vim.api.nvim_command("write")
    local filename = vim.fn.expand("%:t")
    local tmpout = "/tmp/lua_execute_tmp_out"
    local tmperr = "/tmp/lua_execute_tmp_err"
    command = "quickrun -p " .. filename
    local exitcode = os.execute(command .. " > " .. tmpout .. " 2> " .. tmperr)
    local stdout_file = io.open(tmpout)
    local stdout = stdout_file:read("*all")
    stdout_file.close()
    local no_color_stdout = string.gsub(stdout, "\027%[[0-9;]*m", "")
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

-- 1: horizontal, 2: vertical
local termDir = 0
local lastCmd = ""
local toggleTermTab = function()
    if termDir == 0 then
        termDir = 2
    elseif termDir == 1 or termDir == 2 then
        termDir = 0
    end
    vim.cmd("ToggleTerm size=20 direction=horizontal")
end
map({ "n", "i", "v", "t" }, "<S-Tab>", toggleTermTab, { desc = "Toggle terminal" })

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

local compAndRunCur = function()
    vim.cmd("write")
    local filename = vim.fn.expand("%:t")
    lastCmd = "quickrun " .. filename
    if termDir == 2 then
        vim.cmd('TermExec cmd="' .. "quickrun " .. filename .. '"')
    else
        vim.cmd("ToggleTerm size=20 direction=horizontal")
        vim.cmd('TermExec go_back=0 cmd="' .. "quickrun " .. filename .. '"')
        if termDir == 0 then
            termDir = 2
        elseif termDir == 1 or termDir == 2 then
            termDir = 0
        end
        -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, true, true), 'n', true)
    end
end
local compAndRunOther = function()
    if lastCmd == "" then
        return
    end
    vim.cmd('TermExec go_back=0 cmd="' .. lastCmd .. '"')
end

local compAndRun = function()
    local tmpout = "/tmp/window_info_out"
    local window_command = "kitten @ ls"
    os.execute(window_command .. " > " .. tmpout)
    local stdout = io.open(tmpout):read("*all")
    local tt = json_decode(stdout)
    require("notify")(tt, "error")
end

-- map({"n", "i", "v"}, "<C-`>", compAndRunCur)
map({ "n", "i", "v" }, "<C-`>", compAndRun)
map("t", "<C-`>", compAndRunOther)
-- map({"n"}, "<leader>r", compAndRunCur, { desc = "Compile and run" })
-- map("t", "<leader>i", compAndRunOther, { desc = "Compile and run" })

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

map({ "n", "i", "v" }, "<C-S-Left>", "<cmd>BufferLineMovePrev<cr>")
map({ "n", "i", "v" }, "<C-S-Right>", "<cmd>BufferLineMoveNext<cr>")
map({ "n", "i", "v" }, "<S-Left>", "<cmd>BufferLineCyclePrev<cr>")
map({ "n", "i", "v" }, "<S-Right>", "<cmd>BufferLineCycleNext<cr>")

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

function debugProcess()
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

-- local function toggle_term()
--     local size = math.floor(vim.o.columns * 0.5)
--     vim.cmd("ToggleTerm size=" .. size .. " direction=vertical")
--     vim.cmd("ToggleTermOpen")
-- end

-- map({"n", "i", "v", "t"}, "<C-\\>", toggle_term, { desc = "Toggle terminal Vertical" })

local toggleTermWin = function()
    if termDir == 0 then
        termDir = 2
    elseif termDir == 1 or termDir == 2 then
        termDir = 0
    end
    local size = math.floor(vim.o.columns * 0.5)
    vim.cmd("ToggleTerm size=" .. size .. " direction=vertical")
    vim.cmd("wincmd p")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, true, true), "i", true)
end

map("n", "<leader>\\", toggleTermWin, { desc = "Toggle terminal Vertical" })
map("n", "<A-c>", "<cmd>CopilotChatInPlace<CR>", { desc = "Open chat" })

-- kitty and vim integration
map("n", "<C-j>", ":KittyNavigateDown<CR>", { noremap = true, silent = true })
map("n", "<C-k>", ":KittyNavigateUp<CR>", { noremap = true, silent = true })
map("n", "<C-l>", ":KittyNavigateRight<CR>", { noremap = true, silent = true })
map("n", "<C-h>", ":KittyNavigateLeft<CR>", { noremap = true, silent = true })
map("n", "<f2>", "<cmd>ZenMode<CR>", { desc = "Quickrun" })
map("n", "<leader>pmd", "<cmd>MarkdownPreview<CR>", { desc = "Markdown Preview" })
map("n", "<leader>pms", "<cmd>MarkdownPreviewStop<CR>", { desc = "Markdown Preview" })
