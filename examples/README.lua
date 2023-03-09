local files = io.popen("find examples -type f -name '0*.lua' | sort")

local examples = {}
local ret = {
	examples = examples
}

if not files then
	print("No files found")
	return
end

for file in files:lines() do
	local f, code, result
	f = io.open(file, "r")
	if not f then
		print("Failed to open file: " .. file)
		return
	end
	code = f:read("*all")
	result = ""
	local p = print
	print = function(...)
		local args = {...}
		if #args == 1 then
			result = result .. tostring(args[1])
		end
		for i = 2, #args do
			result = result .. "\t" .. tostring(args[i])
		end
		result = result .. "\n"
	end
	local func =loadstring(code)
	if not func then
		error("Failed to load file: " .. file)
	end
	func()
	print = p
	examples[#examples + 1] = {
		name = file,
		code = code,
		result = result
	}
end

return ret
