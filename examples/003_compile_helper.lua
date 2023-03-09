#!/bin/luajit
local handlebars = require("lib.handlebars")
local hb = handlebars.new(nil, {
 Call_lua_function = {
	description = "Call lua function",
	stage = "code_generation",
	idempotent = false,
	unsafe = false,
	block = false,
	func = function(self, token)
		util.printf(...)
	end
}})
local template = hb:compile_template([[
You are invited to the party!
atendess:
{{#each attendess}}
 - {{this}}
{{/each}}
Cant wait to see you there!
]])
print(template({attendess = {"Mike", "John", "Paula", "Josh", "Kate"} }))
