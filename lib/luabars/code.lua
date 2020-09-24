local format = string.format
local concat = table.concat
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
			v[2](table.unpack(v, 3))
			self:_resovle()
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

function _CODE:gen_comment(token)
	for str in string.gmatch(token.value, "[^\n]*") do
		if str ~= nil and string.len(str) > 0 then
			self:emit("--%s\n", str)
		end
	end
end

function _CODE:gen_content(token)
	self:emit("print(%q)", token.value)
end
function _CODE:generate_code(token)
	if token.children then
		for i, v in ipairs(token.children) do
			self:generate_code(v)
		end
	end
	if self["gen_" .. token.type] then
		return self["gen_" .. token.type](self, token)
	else
		print("cant find generator for ", token.type)
		return true
	end
end

function _M.ast_to_code(tokens, vars, prefix)
	if prefix then
		prefix = prefix .. "."
	else
		prefix = ""
	end
	local ret = {
		code = {},
		depth = 0,
		varcount = 0,
		variabels = vars,
		prefix = prefix,
	}
	setmetatable(ret, _MT)
	local r, err = ret:generate_code(tokens)
	if not r then
		return nil, err
	end
	ret:emit("if (%s) then", r)
	return ret:get_code()
end

return _M

