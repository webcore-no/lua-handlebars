#!/bin/luajit
local handlebars = require("lib.handlebars")
local hb = handlebars.new()

local template = hb:compile_template([[Hello, {{name}}!]])
print(template({name = "World"}))
