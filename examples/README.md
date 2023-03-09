# Examples
Here is a list of examples for the lua handlebars library.

## examples/001_basic.lua
```lua
#!/bin/luajit
local handlebars = require("lib.handlebars")
local hb = handlebars.new()

local template = hb:compile_template([[Hello, {{name}}!]])
print(template({name = "World"}))
```
### Result
```
Hello, World!
```
## examples/002_each.lua
```lua
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
```
### Result
```
You are invited to the party!
atendess:
 - Mike
 - John
 - Paula
 - Josh
 - Kate
Cant wait to see you there!

```

