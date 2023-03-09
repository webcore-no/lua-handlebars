local util = require("lib.handlebars.util");
local parser = require("lib.handlebars.parser")
local code = require("lib.handlebars.code")
local default_helpers = require("lib.handlebars.helpers")
local optimizer = require("lib.handlebars.optimizer")


local _T = {}

local bars_mt = {}
local bars = { __index = bars_mt }

function bars_mt:register_helper(key, value)
	self.helpers[key] = value
end

function bars_mt:register_helpers(tbl)
	for k, v in pairs(tbl) do
		self:register_helper(k,v)
	end
end

function bars_mt:register_helpers_file(path)
	local file, data, tbl, err
	file, err = io.open(path, 'r+')
	if not file then
		return false, err
	end
	data, err = file:read('*all')
	if not data then
		return false, err
	end

	data, err = loadstring(data)
	if not data then
		return false, err
	end
	tbl = data() or {}
	for k, v in pairs(tbl) do
		self:register_helper(k,v)
	end
	return true
end


function bars_mt:compile_template(data)
	local ast, err, c, f
	-- Remove trailing whitespace added by lua
	ast, err = parser.parse(data)
	if not ast then
		return nil, err
	end
	optimizer.optimize(ast)

	c, err = code.ast_to_code(ast, self.helpers_path, self.helpers)
	if not c then
		return nil, err
	end
	f, err = loadstring(c)
	if not f then
		return nil, err
	end
	return f()
end

function bars_mt:compile_template_file(path)
	local file, data, err
	file, err = io.open(path, 'r+')
	if not file then
		return nil, err
	end
	data, err = file:read('*all')
	if not data then
		return nil, err
	end
	-- Remove trailing whitespace added by lua
	data = data:sub(1, -2)
	return self:compile_template(data)
end

function _T.new(helpers_path, helpers)
	local t = {
		helpers = helpers or {},
		helpers_path = helpers_path
	}
	setmetatable(t, bars)
	return t
end

return _T
