local util = require("lib.handlebars.util")

local _M = {}

function _M:log(...)
	util.err_printf(...)
end

return _M
