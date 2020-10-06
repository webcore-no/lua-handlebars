local cjson = require("cjson.safe")

local util = require("lib.luabars.util")
local err_printf = util.err_printf

local format = string.format
local concat = table.concat
--local unpack = table.unpack
local str_rep = string.rep

local _CODE = {}
local _M = {}
local _MT = {__index = _CODE}


function _CODE:emit(fmt, ...)
	if type(fmt) == "function" then
		self.code[#self.code + 1] = {self.depth, fmt, ...}
		return
	end
	self.code[#self.code + 1] = str_rep('    ', self.depth) .. format(fmt, ...)
end

function _CODE:emit_raw(fmt)
	self.code[#self.code + 1] = str_rep('    ', self.depth) .. fmt
end
function _CODE:scope(up, content, else_content)
	self:scope_up(up)
	content()
	if else_content then
		self:scope_else()
		else_content()
	end
	self:scope_down()
end

function _CODE:scope_up(l, ...)
	self:emit(l, ...)
	self.depth = self.depth + 1
end

function _CODE:scope_else(l, ...)
	self.depth = self.depth - 1
	if l then
		self:scope_up(l, ...)
	else
		self:scope_up("else")
	end
end

function _CODE:scope_down()
	self.depth = self.depth - 1
	self:emit("end")
end

function _CODE:resovle()
	local old_depth = self.depth
	local old_code = self.code
	for i, v in ipairs(self.code) do
		if type(v) == "table" then
			local new_code = {}
			self.code = new_code
			self.depth = v[1]
			v[2](unpack(v, 3))
			self:resovle()
			old_code[i] = concat(new_code, "\n")
		end
	end
	self.depth = old_depth
	self.code = old_code
end

function _CODE:get_code()
	self:resovle()
	return concat(self.code, '\n')
end

function _CODE:gen_defines()
	for k, v in ipairs(self.defines) do
		self:emit('local d%d = %s', k, v)
	end
end

function _CODE:define(def)
	for k, v in ipairs(self.defines) do
		if v == def then
			return format('d%d', k)
		end
	end
	self.defines[#self.defines + 1] = def
	return format('d%d', #self.defines)
end

function _CODE:helper(name, data)
	if self.inline_helpers[name] then
		return self.inline_helpers[name](self, data)
	end
	if self.helpers[name] then
		local fn = self:define('helper.%s', name)
		local args, err = self:unwrap_args(data)
		if not args then
			return nil, err
		end
		return format('%s(%s)', fn, args)
	end
	return nil, format("helper %q does not exist", name)
end

function _CODE:gen_comment(token)
	for str in string.gmatch(token.value, "[^\n]*") do
		if str ~= nil and string.len(str) > 0 then
			self:emit("--%s\n", str)
		end
	end
end

function _CODE:gen_block(token)
	local o, err = self:helper(token.name.value, token)
	if not o then
		return err
	end
end
function _CODE:resolve_param(param)
	if param.type == 'path' then
		if param.value == 'this' then
			return 'self'
		end
		return format('self.%s', param.value)
	elseif param.type == 'string' then
		return format('%s', util.escape_string(param.value))
	elseif param.type == 'boolean' then
		if param.value then
			return '"true"'
		else
			return '"false"'
		end
	elseif param.type == 'number' then
		return format('%q', tostring(param.value))
	elseif param.type == 'undefined' then
		return '"undefined"'
	elseif param.type == "dataName" then
		return param.value
	else
		return nil, format('unsupported type %q', param.type)
	end
end

function _CODE:gen_mustache(token)
	if #token.params ~= 0 then
		-- We have params
		local m, err = self:helper(token.helper.value, token)
		if not m then
			return err
		end
		if #m ~= 0 then
			self:emit('%s', m)
		end
	else
		local res, err = self:resolve_param(token.helper)
		if not res then
			return err
		end
		local w = self:define('function(...)io.stdout:write(...)end')
		self:emit('%s(%s)', w, res)
	end
end
function _CODE:gen_root(token)
	-- Do nothing since root is only a meta construct
	-- TODO: Add startup logic here
	self:scope_up('return function(self)')
	if token.value.children then
		for i, v in ipairs(token.value.children) do
			err = self:generate_code(v)
			if err then
				return err
			end
		end
	end
	self:scope_down('end')
end

function _CODE:gen_content(token)
	local w = self:define('function(...)io.stdout:write(...)end')
	self:emit("%s(%s)", w, util.escape_string(token.value))
end
function _CODE:generate_code(token)
	local err
	if not token.type then
		err_printf("Cant find token type for: %s", cjson.encode(token))
		return
	end
	if self["gen_" .. token.type] then
		err = self["gen_" .. token.type](self, token)
		if err then
			return err
		end
	else
		err_printf("cant find start callback for %s", token.type)
	end
end

function _M.ast_to_code(tokens, helpers, inline_helpers)
	err_printf("tokens:\n\n%s\n\n", cjson.encode(tokens))
	local ret = {
		helpers = helpers or {},
		inline_helpers = inline_helpers or {},
		code = {},
		depth = 0,
		defines = {},
	}
	setmetatable(ret, _MT)
	ret:emit(ret.gen_defines, ret)
	local err = ret:generate_code(tokens)

	if err then
		return nil, err
	end

	err_printf("code:\n\n%s\n\n", ret:get_code())
	return ret:get_code()
end

return _M

