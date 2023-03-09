#!/bin/luajit
local handlebars = require("lib.handlebars")
local hb = handlebars.new()
local template = hb:compile_template([[
You are invited to the party!
atendess:
{{#each attendess}}
 - {{this}}
{{/each}}
Cant wait to see you there!
]])
print(template({attendess = {"Mike", "John", "Paula", "Josh", "Kate"} }))
