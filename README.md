# Lua handlebars
A handlebars like template library for lua.

## Helpers

## format
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```run```


format string
### Example
```handlebars
{{format "Hello there %q!" "World"}}

```
## log

stage: ```run```


Log to stdout
### Example
```handlebars
<a>foo</a>{{log "Hello world"}}
<a>bar</a>

```
## lower
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```run```


Lowercase string
### Example
```handlebars
{{lower "UPPERCASE IS CRUISE CONTROL FOR COOL"}}

```
## gsub
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```run```


Replaces all occurrences of a pattern in a string with a replacement string.
### Example
```handlebars
{{gsub "all the space are belong to us" " " "" }}

```
## unless
<a style="margin: 4px;color: white;background: #5757b5;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#block">
Block
</a>
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```code_generation```


Unless block
### Example
```handlebars
{{#unless nothing}}
foobar
{{/unless}}

```
## err_log

stage: ```run```


Log to stderr
## if
<a style="margin: 4px;color: white;background: #5757b5;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#block">
Block
</a>
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```code_generation```


If block
### Example
```handlebars
{{#if isFoo}}<a>foo</a>
{{else}}<a>bar</a>
{{/if}}
{{#if isBar}}<div>bar</div>
{{else}}<div>foo</div>
{{/if}}

```
## sub
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```run```


Extract substring
### Example
```handlebars
{{sub "mylongstring" 3 -1}}

```
## upper
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```run```


Uppercase string
### Example
```handlebars
{{upper "I want to be uppercase"}}

```
## each
<a style="margin: 4px;color: white;background: #5757b5;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#block">
Block
</a>
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```code_generation```


Each block
### Example
```handlebars
{{#each a}}<a>{{this}}</a>
{{/each}}

{{#each b}}<a>{{this}}</a>
{{else}}<a>No b</a>
{{/each}}

{{#each a}}<a>{{@key}}</a>
<a>{{@index}}</a>
{{else}}<a>No b</a>
{{/each}}

```
## with
<a style="margin: 4px;color: white;background: #5757b5;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#block">
Block
</a>
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```code_generation```


With block
### Example
```handlebars
{{#with a}}
<a> name: {{name}}</a>
<a> address: {{addr}}</a>
{{/with}}

```
## gmatch
<a style="margin: 4px;color: white;background: #5757b5;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#block">
Block
</a>
<a style="margin: 4px;color: white;background: #55bd63;border-radius: 10px;padding: 2px;padding-left: 7px;padding-right: 7px;" href="./docs/helper.md#idempotent">
Idempotent
</a>

stage: ```code_generation```


Iterate trough a matches of a pattern see lua patterns
### Example
```handlebars
{{#gmatch "one, two, three" "%w+"}}
{{this}}
{{/gmatch}}

```

## Requiremnets
 - [LPEG](http://www.inf.puc-rio.br/~roberto/lpeg/)
