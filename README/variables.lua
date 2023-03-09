local helpers = require('lib/handlebars/helpers')

local examples = io.popen('find t -type f -regex ".*/*.hbs"')

if not examples then
	error('Could not find examples')
end

for example in examples:lines() do
	local name = example:match('t/%d%d%d[-](.*)/.*[.]hbs')
	if name and helpers[name] then
		local data = io.open(example, 'r'):read('*all')
		helpers[name].example = data
	end
	-- local f = io:open(example, 'r')
end

return {
	helpers = helpers
}
