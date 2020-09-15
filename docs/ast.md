
All nodes has 'type' field

# Types

## print
### Fields
#### value
The value to output into the text document
### Exsample
``` json
{
	"type": "print",
	"value": "foobar'
}
```
``` lua
print('foobar')
```
## pair
### Fields
#### Value
What variable to iterate
### Example
```json
{
	"type": "pair",
	"value": "foo",
	"children: {...},
}
```
```lua
local first = next(foo)
for key, value in pairs(foo)
...
end
```
## ipair
### Fields
#### Value
What variable to iterate
### Example
```json
{
	"type": "ipair",
	"value": "foo",
	"children: {...},
}
```
```lua
local first = foo[1]
local last = foo[#foo]
for index, value in ipairs(foo)
...
end
```
###
 - while/for(repeat the action)
