local util = require("lib.luabars.util")
local cjson = require("cjson.safe")
local util = require("lib.luabars.util")
local err_printf = util.err_printf



local _M = {
	['if'] = function(self, token)
		if #(token.params) ~= 1 then
			return nil, "#if requires exactly one argument"
		end
		local cond, err = self:resolve_param(token.params[1])
		if not cond then
			return nil, err
		end

		self:scope_up("if %s then", cond)
		if token.children then
			for i, v in ipairs(token.children) do
				err = self:generate_code(v)
				if err then
					return err
				end
			end
		end
		if token.inverse then
			self:scope_else()
			if token.inverse.children then
				for i, v in ipairs(token.inverse.children) do
					err = self:generate_code(v)
					if err then
						return nil, err
					end
				end
			end
		end
		self:scope_down()
		return ''
	end,
}
function _M:unless(token)
	if #(token.params) ~= 1 then
		return nil, "#unless requires exactly one argument"
	end
	local cond, err = self:resolve_param(token.params[1])
	if not cond then
		return nil, err
	end

	self:scope_up("if not (%s) then", cond)
	if token.children then
		for i, v in ipairs(token.children) do
			err = self:generate_code(v)
			if err then
				return err
			end
		end
	end
	if token.inverse then
		self:scope_else()
		if token.inverse.children then
			for i, v in ipairs(token.inverse.children) do
				err = self:generate_code(v)
				if err then
					return nil, err
				end
			end
		end
	end
	self:scope_down()
	return ''
end

function _M:each(token)
	if #(token.params) ~= 1 then
		return nil, "#each requires exactly one argument"
	end
	local param, err = self:resolve_param(token.params[1])
	if not param then
		return nil, err
	end
	self:emit("local arr = %s or {}", param)
	self:scope_up("for key, self in pairs(arr) do")
	self:emit("local index = key", param)
	
	local path = self:_resolve_path(token.params[1])
	path[#path+1] = { type="array", value="key" }
	self:self_push(path)

	if token.children then
		for i, v in ipairs(token.children) do
			err = self:generate_code(v)
			if err then
				return nil, err
			end
		end
	end
	if token.inverse then
		self:self_pop()
		path[#path] = nil
		err_printf(cjson.encode(path))
		self:self_push(path)
		self:scope_down()
		self:scope_up("if #(arr) and not next(arr) then")
		if token.inverse.children then
			for i, v in ipairs(token.inverse.children) do
				err = self:generate_code(v)
				if err then
					return nil, err
				end
			end
		end
	end
	self:self_pop()
	self:scope_down()
	return ''
end


function _M:with(token)
	if #(token.params) ~= 1 then
		return nil, "#with requires exactly one arguments"
	end
	local param, err = self:resolve_param(token.params[1])
	if not param then
		return nil, err
	end
	self:scope_up("do", param)
	self:emit("local self = %s", param)
	local path = self:_resolve_path(token.params[1])
	self:self_push(path)
	if token.children then
		for i, v in ipairs(token.children) do
			err = self:generate_code(v)
			if err then
				return nil, err
			end
		end
	end
	self:self_pop()
	self:scope_down()
	return ''
end

function _M:log(token)
	local fn = self:define('function(...)io.stderr:write(...)end')
	err_printf(cjson.encode(token))
	self:emit("%s(%s)", fn, util.escape_string(token.params[1].value))
end

return _M
