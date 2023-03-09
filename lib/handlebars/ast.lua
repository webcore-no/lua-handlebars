
local _T = {}
local ast_mt = {}
local ast = { __index = ast_mt }


function ast_mt:run(root, token)
	-- Run helpers for this stage if relevant
	if token.type == 'block' or (token.type == 'mustache' and #token.params > 0) then
		local helper = self.helpers[token.name]
		if helper and helper.stage == 'ast' then
			helper.func(root, token)
		end
	end
	if token.value and  token.value.children then
		for _, v in ipairs(token.value.children) do
			self:run(root, v)
		end
	end
	return nil
end


function _T.run_helpers(token, helpers)
	local t = {
		helpers = helpers,
	}
	setmetatable(t, ast)
	return t:run(token, token)
end


return _T

