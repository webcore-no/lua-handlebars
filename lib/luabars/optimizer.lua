local _M = {}

-- Nearest neighbur print
local function print_merge(ast)
	for i, v in ipairs(ast) do
		if v.type == "print" then
			if ast.children[i+1].type == "print" then
				v.value = v.value + ast.children
			end
		end
		print_merge(v)
	end
	return true
end
local optimizers = {
	{
		name = "Print merge",
		description = "Merges print statements that are after eachother",
		cost = 1,
		func = print_merge
	}
}


function _M.optimize(ast)
	for _, v in pairs(optimizers) do
		v.func(ast)
	end
end

return _M

