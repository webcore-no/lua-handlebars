local util = require("lib.luabars.util")

local _M = {
	['if'] = function(token)
		if #(token.params) ~= 1 then
			return nil, "#if requires exactly one argument"
		end
		local conditional = token.params[1]
		
		local cond
		-- If conditional is subexprs
		if conditional.type == "sexpr" then
			cond = self:define(conditional.value)
		else
			cond = conditional.value
		end

		self:scope_up("if %s", cond)
		if options.children then
			for i, v in ipairs(token.children) do
				err = self:generate_code(v)
				if err then
					return err
				end
			end
		end
		if token.inverse then
			self:scope_else()
			self:generate_code(token.inverse)
		end
		self:scope_down()
	end,
}

function _M.log(token)
	local fn = self:define('io.stderr:write')
	err_printf(cjson.encode(token))
	self:emit("%s(%s)", fn, util.escape_string(token.params[1].value))
end

return _M
