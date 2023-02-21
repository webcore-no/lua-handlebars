local format = string.format

local _M = {}

function _M.err_printf(...)
	io.stderr:write(format(...))
	io.stderr:write('\n')
end

function _M.escape_string(str)
	local quote = '"'

	str = str:gsub("\\", [[\\]])
	str = str:gsub("\n", [[\n]])
	str = str:gsub("\b", [[\b]])
	str = str:gsub("\t", [[\t]])
	str = str:gsub("\f", [[\f]])
	str = str:gsub("\r", [[\r]])
	str = str:gsub('"', '\\"')

	return format([["%s"]], str)
end
return _M

