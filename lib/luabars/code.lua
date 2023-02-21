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

local print_func = "function(table, text)table[#table+1] = text end"

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

function _CODE:self_push(path)
	self.self_stack[#self.self_stack+1] = path
end

function _CODE:self_pop()
	local s = self.self_stack[#self.self_stack]
	self.self_stack[#self.self_stack] = nil
	return s
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
	local name = token.name.value.value[1]
	local o, err = self:helper(name, token)
	if not o then
		return err
	end
end
function _CODE:_resolve_path(param)
	if param.type == 'path' or param.type == 'dataName' then
		local r_path = {}

		-- If path add existing path
		if param.type == 'path' then
			if param.value.value[1] == 'this' then
				param.value.value[1] = nil
			end

			-- Fill with exsisting stack
			for k, v in ipairs(self.self_stack[#self.self_stack]) do
				r_path[#r_path+1] = v
			end
		end

		for k, v in ipairs(param.value.value) do
			if v == '..' then
				if #r_path <= 1 then
					return nil, format("Invalid path")
				end
				r_path[#r_path] = nil
			else
				r_path[#r_path+1] = { type="path", value=v }
			end
		end
		return r_path
	end
	return nil, format('unsupported type %q', param.type)
end

local path_to_string = function(path)
	local str = ""
	for k, v in ipairs(path) do
		if v.type == "path" then
			if str == "" then
				str = v.value
			else
				str = format("%s.%s", str, v.value)
			end
		elseif v.type == "array" then
			str = format("%s[%s]", str, v.value)
		else
			err_printf(cjson.encode(path))
			return nil, format("unsupported segement %q", v.type)
		end
	end
	return str
end

function _CODE:resolve_param(param)
	if param.type == 'path' or param.type == "dataName" then
		local resolved_path, err = self:_resolve_path(param)
		if not resolved_path then
			return nil, err
		end
		return path_to_string(resolved_path)
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
	else
		return nil, format('unsupported type %q', param.type)
	end
end

function _CODE:gen_mustache(token)
	if #token.params ~= 0 then
		-- We have params
		local name = token.helper.value.value[1]
		local m, err = self:helper(name, token)
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
		local w = self:define(print_func)
		self:emit('%s(out, %s)', w, res)
	end
end
function _CODE:gen_root(token)
	-- Do nothing since root is only a meta construct
	-- TODO: Add startup logic here
	self:scope_up('return function(root)')
	self:self_push({{type="path", value="root"}})

	local concat = self:define("table.concat")
	self:emit("local out = {}")

	if token.value.children then
		for i, v in ipairs(token.value.children) do
			err = self:generate_code(v)
			if err then
				return err
			end
		end
	end

	self:emit("return %s(out)", concat)
	self:self_pop()
	self:scope_down('end')
end

function _CODE:gen_content(token)
	local w = self:define(print_func)
	self:emit("%s(out, %s)", w, util.escape_string(token.value))
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
		self_stack = {},
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

