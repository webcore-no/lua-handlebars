local util = require("lib.luabars.util")
local cjson = require("cjson.safe")
local format = string.format
local err_printf = util.err_printf
local read_file = util.read_file

local _M = {}

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
		self.helpers[k] = v
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
		self.helpers[k] = v
	end
end

return _M
