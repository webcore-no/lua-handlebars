local util = require("lib.luabars.util")

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

function _M:log(token)
	local fn = self:define('io.stderr:write')
	err_printf(cjson.encode(token))
	self:emit("%s(%s)", fn, util.escape_string(token.params[1].value))
end

return _M
