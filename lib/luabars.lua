local re = require("relabel")
local format = string.format
local util = require("lib.luabars.util")
local err_printf = util.err_printf

local code = require("lib.luabars.code")

local _M = {}
local terror = {eof = "expected end of file"}

local comp = re.compile([[
   root <-  {|{:type: '' -> 'root':} {:children: program :} |} (!. / %{eof})
   program <- {| statement* |}
   statement <- {| {:type: '' -> 'comment' :} {:value: comment :} |}
               / {| {:type: '' -> 'content' :} {:value: content :} |}
               / {| {:type: '' -> 'partialBlock' :} {:value: partialBlock :} |}
               / {| {:type: '' -> 'partial' :} {:value: partial :} |}
               / {| {:type: '' -> 'rawBlock':} {:value: rawBlock :} |}
               / {| {:type: '' -> 'block':} {:value: block :} |}
               / {| {:type: '' -> 'mustache' :} {:value:  mustache :} |}

   comment <-  '{{!--' {(!('--' close) .)* } '--' close
            /  '{{!' { (!close .)* } close


   content <- {:content: (!open .)+ :}

   rawContent <- (!(open open) .)+

   partialBlock <- {| openPartialBlock {:children: {| program |} :}|} closeBlock

   partial <- {| open '>' space* partialName space* {:params: {| (!hash param space*)* |} :} space* {:hash: hash? :} space* close |}

   rawBlock <- openRawBlock (rawContent)* endRawBlock
   openRawBlock <- open open helperName (!hash param)* hash? close close
   endRawBlock <- open open '/' helperName close close

   block <- {| openBlock {:childern: {| program |} :} |} inverseChain? closeBlock
         / openInverse program inverseAndProgram? closeBlock
   mustache <- open space* {| {:helper: helperName :} {:params: {| param*|} :} hash? |} space* close

   openInverse <- open '^' helperName param* hash? blockParams? close
   inverseChain <- openInverseChain program inverseChain?
   openInverseChain <- open space* 'else' helperName param* hash? blockParams? close

   inverseAndProgram <- inverse program

   inverse <- open '^'? space* close

   openPartialBlock <- open '#>' space* {| {:name: partialName :} space* (!hash param space*)* |} space* hash? space* close

   partialName <- {| {:type: ''->'helperName':}{:value: helperName :} |}
               / {| {:type: '' -> 'sexpr':} {:value: sexpr :} |}

   helperName <- {| {:type: '' -> 'path' :} {:value: path :} |}
               / {| {:type: '' -> 'dataName' :} {:value: dataName :} |}
               / {| {:type: '' -> 'string' :} {:value: string :} |}
               / {| {:type: '' -> 'number' :} {:value: number :} |}
               / {| {:type: '' -> 'boolean' :} {:value: boolean :} |}
               / {| {:type: '' -> 'undefined' :} {:value: undefined :} |}
               / {| {:type: '' -> 'null' :} {:value: null :} |}

   openBlock <- open '#' '*'? space* {:name: helperName :} space* {:children: {| (!hash param space*)* |}:} hash? space* blockParams? space* close
   closeBlock <- open '/' helperName close

   sexpr <- '(' helperName param* hash? ')'

   blockParams <- openBlockParams id closeBlockParams
   openBlockParams <- 'as' [\s]+ '|'
   closeBlockParams <- '|'
   param <- {| {:type: ''->'helperName':}{:value: helperName :} |}
         / {| {:type: '' -> 'sexpr':} {:value: sexpr :} |}

   hash <- {| hashSegment+ |}

   hashSegment <- {| {:id: id :} space* '=' space* {:param: param :} |}

   dataName <- data pathSegments

   path <- pathSegments
   pathSegments <- id (sep id)*
                / (id / '.' / '..') ( '/' (id / '.' / '..'))*

   data <- '@'
   id <- (![=~}%s/.)|] .)+
   string <- '"'('\"' / [^"])*'"'
           / "'"("\'" / [^'])*"'"
   number <- '-'? [0-9]+ ([:.][0-9]+)?
   boolean <- 'true' / 'false'
   undefined <- 'undefined'
   null <- 'null'

   sep <- [/.]
   close <- '}}'
   open <- '{{'
   space <- [%s]
]], terror)

local sample = [[
<a>some content</a>
{{! comment
text }}
{{!-- another comment
 lul }} --}}
{{>person foo bar person=.}}
{{#> childEntry}}
{{/childEntry}}
{{{{raw-helper}}}}
   {{bar}}
{{{{/raw-helper}}}}
<div>{{#noop}}{{body}}<div class="styling"/>{{/noop}}</div>
<p>{{#while true}}{{/while}}</p>
<div>
{{#with person}}
   {{#with names}}
      <p>{{this}}</p>
      {{/with}}
{{/with}}
{{# each persons}}
{{/each}}
</div>
]]

local function mymatch(g, s)
	local r, e, pos = g:match(s)
	if not r then
		local line, col = re.calcline(s, pos)
		-- local msg = "Error at line " .. line .. " (col " .. col .. "): "
		return r, format('%d col:%d %s', line, col, terror[e])
	end
	return r
end
function _M.from_file(path)
	local file, ast, err, c
	file, err = io.open(path, 'r+')
	if not file then
		err_printf(err)
		return
	end
	data, err = file:read('*all')
	if not data then
		err_printf(err)
		return
	end
	-- Remove trailing whitespace added by lua
	data = data:sub(1, -2)
	ast, err = mymatch(comp, data)
	if not ast then
		err_printf("%s:%s", path, err)
		return
	end
	c, err = code.ast_to_code(ast)
	if not c then
		err_printf("[ERROR] %s", err)
		return
	end
	return loadstring(c)()
end
return _M

