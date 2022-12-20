local format = string.format
local util = require("lib.luabars.util")
local err_printf = util.err_printf

local parser = require("lib.luabars.parser")
local code = require("lib.luabars.code")
local base_helpers = require("lib.luabars.helpers")
local inline_helpers = require("lib.luabars.inline_helpers")

local _M = {
	helpers = helpers,
	inline_helpers = inline_helpers
}

function _M:register_helper(key, value)
	self.helpers[key] = value
end
function _M:register_inline_helper(key, value)
	self.inline_helpers[key] = value
end


function _M.from_file(path)
	local file, ast, err, c, f
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
	c, err = code.ast_to_code(ast, helpers, inline_helpers)
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
return _M

