local optimizers = {}
local _M = {optimizers = optimizers}

-- Nearest neighbur print
optimizers.name = "Print merge"
optimizers.description = "Merges print statements that are after eachother"
optimizers.cost = 1
local print_merge = function(ast)
	for i, v in ipairs(ast.children) do
		if v.type == "print" then
			if ast.children[i+1].type = "print" then
				v.value = v.value + ast.children
			end
		end
		print_merge(v)
	end
	return true
end

optimizers.func = print_merge

function _M.optimize(ast)
	for k, v in pairs(optimizers) do

	end
end

return _M

