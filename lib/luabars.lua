local util = require("lib.luabars.util")
local parser = require("lib.luabars.parser")
local code = require("lib.luabars.code")
local base_helpers = require("lib.luabars.helpers")
local inline_helpers = require("lib.luabars.inline_helpers")
local optimizer = require("lib.luabars.optimizer")

local err_printf = util.err_printf
local shallow_copy = util.shallow_copy

local _T = {}

local bars_mt = {}
local bars = { __index = bars_mt }

function bars_mt:register_helper(key, value)
	self.helpers[key] = value
end
function bars_mt:register_inline_helper(key, value)
	self.inline_helpers[key] = value
end

function bars_mt:from_string(data)
	local ast, err, c, f
	-- Remove trailing whitespace added by lua
	ast, err = parser.parse(data)
	if not ast then
		err_printf("%s:%s", path, err)
		return
	end
	optimizer.optimize(ast)

	c, err = code.ast_to_code(ast, self.base_helpers, self.inline_helpers)
	if not c then
		err_printf("[ERROR] %s", err)
		return
	end
	f, err = loadstring(c)
	if not f then
		err_printf("[ERROR] %s", err)
		return
	end
	return f()
end

function bars_mt:from_file(path)
	local file, data, ast, err, c, f
	file, err = io.open(path, 'r+')
	if not file then
		err_printf(err)
		return
	end
	data, err = file:read('*all')
	if not data then
		err_printf(err)
		return
	end
	-- Remove trailing whitespace added by lua
	data = data:sub(1, -2)
	ast, err = parser.parse(data)
	if not ast then
		err_printf("%s:%s", path, err)
		return
	end
	optimizer.optimize(ast)

	c, err = code.ast_to_code(ast, self.base_helpers, self.inline_helpers)
	if not c then
		err_printf("[ERROR] %s", err)
		return
	end
	f, err = loadstring(c)
	if not f then
		err_printf("[ERROR] %s", err)
		return
	end
	return f()
end

function _T.new()
	local t = {
		helpers = shallow_copy(base_helpers),
		inline_helpers = shallow_copy(inline_helpers)
	}
	setmetatable(t, bars)
	return t
end

return _T
