local format = string.format

local _M = {}

function _M.err_printf(...)
	io.stderr:write(format(...))
	io.stderr:write('\n')
end
return _M

