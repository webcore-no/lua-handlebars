local util = require("lib.handlebars.util")
local cjson = require("cjson.safe")
local format = string.format
local err_printf = util.err_printf
local read_file = util.read_file

local _M = {}

function _M:helpers(token)
	local helpers, ok, err
	if #(token.params) ~= 1 then
		return nil, "helpers requires exactly one arguments"
	end
	if token.params[1].type ~= "string" then
		return nil, "helpers_file only accepts string"
	end
	helpers, err = loadstring(token.params[1].value)
	if not helpers then
		return nil, err
	end
	ok, helpers = pcall(helpers)
	if not ok then
		return nil, helpers
	end
	if type(helpers) ~= "table" then
		return nil, format("helpers need to return table not %s", type(helpers))
	end
	for k, v in pairs(helpers) do
		self.helpers[k] = v
	end
end

function _M:helpers_file(token)
	local data, helpers, err, ok
	if #(token.params) ~= 1 then
		return nil, "helpers_file requires exactly one arguments"
	end
	if token.params[1].type == "string" then
		return nil, "helpers_file only accepts string"
	end
	data, err = read_file(token.params[1].value)
	if err ~= nil then
		return nil, err
	end
	helpers, err = loadstring(data)
	if not helpers then
		return nil, err
	end
	ok, helpers = pcall(helpers)
	if not ok then
		return nil, helpers
	end
	if type(helpers) ~= "table" then
		return nil, format("helpers_file need to return table not %s", type(helpers))
	end
	for k, v in pairs(helpers) do
		self.helpers[k] = v
	end
end

function _M:inline_helpers(token)
	local inline_helpers, ok, err
	if #(token.params) ~= 1 then
		return nil, "inline_helpers requires exactly one arguments"
	end
	if token.params[1].type ~= "string" then
		return nil, "inline_helpers_file only accepts string"
	end
	inline_helpers, err = loadstring(token.params[1].value)
	if not inline_helpers then
		return nil, err
	end
	ok, inline_helpers = pcall(inline_helpers)
	if not ok then
		return nil, inline_helpers
	end
	if type(inline_helpers) ~= "table" then
		return nil, format("inline_helpers need to return table not %s", type(inline_helpers))
	end
	for k, v in pairs(inline_helpers) do
		self.inline_helpers[k] = v
	end
end

function _M:inline_helpers_file(token)
	local data, inline_helpers, err, ok
	if #(token.params) ~= 1 then
		return nil, "inline_helpers_file requires exactly one arguments"
	end
	if token.params[1].type == "string" then
		return nil, "inline_helpers_file only accepts string"
	end
	data, err = read_file(token.params[1].value)
	if err ~= nil then
		return nil, err
	end
	inline_helpers, err = loadstring(data)
	if not inline_helpers then
		return nil, err
	end
	ok, inline_helpers = pcall(inline_helpers)
	if not ok then
		return nil, inline_helpers
	end
	if type(inline_helpers) ~= "table" then
		return nil, format("inline_helpers_file need to return table not %s", type(inline_helpers))
	end
	for k, v in pairs(inline_helpers) do
		self.inline_helpers[k] = v
	end
end

return _M
