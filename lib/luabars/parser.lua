local re = require("re")
local format = string.format


local _M = {}


local comp = re.compile([[
   root <-  {|{:type: '' -> 'root':} {:value: {| {:children: program :} |} :} |} (!.)
   program <- {| statement* |}
   statement <- {| {:type: '' -> 'comment' :} {:value: comment :} |}
               / {| {:type: '' -> 'content' :} {:value: content :} |}
               / {| {:type: '' -> 'partialBlock' :} {:value: partialBlock :} |}
               / {| {:type: '' -> 'partial' :} {:value: partial :} |}
               / {| {:type: '' -> 'rawBlock':} {:value: rawBlock :} |}
               / {: block :}
               / {:  mustache :}

   comment <-  '{{!--' {(!('--' close) .)* } '--' close
            /  '{{!' { (!close .)* } close


   content <- {:content: (!open .)+ :}

   rawContent <- (!(open open) .)+

   partialBlock <- {| openPartialBlock {:children: program :}|} closeBlock

   partial <- {| open '>' space* partialName space* {:params: {| (!hash param space*)* |} :} space* {:hash: hash? :} space* close |}

   rawBlock <- openRawBlock (rawContent)* endRawBlock
   openRawBlock <- open open helperName (!hash param)* hash? close close
   endRawBlock <- open open '/' helperName close close

   block <-{| {:type: '' -> 'block':} openBlock {:children: {| (!inverseChain statement)* |} :} {:inverse: inverseChain :}? closeBlock |}
         / openInverse program inverseAndProgram? closeBlock

   mustache <- {| {:type: '' -> 'mustache' :} open space* {:helper: helperName :} space* {:params: {| (!hash {: param :} space*)* |}:} hash? |} space* close newline?

   openInverse <- open '^' helperName param* hash? blockParams? close
   inverseChain <- {| {:type: '' -> "inverse_chain" :} openInverseChain {:children: {| (!inverseChain statement)* |} :} {:inverse: inverseChain? :} |}
   openInverseChain <- open space* 'else' space* {:name: helperName :}? space* {:params: {| param*  space* |} :} hash? blockParams? close newline?

   inverseAndProgram <- inverse program

   inverse <- open '^'? space* close

   openPartialBlock <- open '#>' space* {| {:name: partialName :} space* (!hash param space*)* |} space* hash? space* close

   partialName <- helperName
               / sexpr

   helperName <- {| {:type: '' -> 'null' :} {:value: null :} |}
               / {| {:type: '' -> 'undefined' :} {:value: undefined :} |}
               / {| {:type: '' -> 'boolean' :} {:value: boolean :} |}
               / {| {:type: '' -> 'number' :} {:value: number :} |}
               / {| {:type: '' -> 'string' :} {:value: string :} |}
               / {| {:type: '' -> 'dataName' :} {:value: dataName :} |}
               / {| {:type: '' -> 'path' :} {:value: path :} |}

   openBlock <- open '#' '*'? space* {:name: helperName :} space* {:params: {| (!hash {: param :} space*)* |}:} hash? space* blockParams? space* close newline?
   closeBlock <- open '/' helperName close newline?

   sexpr <- '(' helperName param* hash? ')'

   blockParams <- openBlockParams id closeBlockParams
   openBlockParams <- 'as' [\s]+ '|'
   closeBlockParams <- '|'
   param <- helperName
         / sexpr

   hash <- {| hashSegment+ |}

   hashSegment <- {| {:id: id :} space* '=' space* {:param: param :} |}

   dataName <- data {: pathSegments :}

   path <- pathSegments
   pathSegments <- {| {:type: '' -> 'url' :}{:value: {| segmentPart ( '/' (segmentPart))* |} :} |}
                   /{| {:type: '' -> 'dot':} {:value: {| {: id :} (sep {: id :})* |} :} |}
   segmentPart <- {: '..' / '.' / id :}
   data <- '@'
   id <- (![=~}%s/.)|] .)+
   string <- '"'{:('\"' / [^"])*:}'"'
           / "'"{:("\'" / [^'])*:}"'"
   number <- '-'? [0-9]+ ([:.][0-9]+)?
   boolean <- 'true' / 'false'
   undefined <- 'undefined'
   null <- 'null'

   sep <- [/.]
   close <- '}}'
   open <- '{{'
   space <- [%s]
   newline <- [%nl]
]])

function _M.parse(s)
	local r, e, pos = comp:match(s)
	if not r then
		return r, format('error %s %s', e, pos)
	end
	return r
end

return _M
