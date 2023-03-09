# TODO
 - [X] Write test and fix helpers
 - [X] Write a cli that supports helper input
 - [ ] Write a more robust and prettier test framework
 - [ ] Write luarocks spec
 - [X] Write a better README (generate with a input.hbs)
 - [X] Write a LICENSE
 - [ ] Write CI/CD pipelines
 - [ ] Build docs in pipeline
 - [ ] Add to some lua awsome lists
 - [ ] Export to lua resty package manager
 - [X] Rename 'inline' to 'compiler'
 - [ ] Add 'ast' helper
 - [ ] Add 'description', 'idempotent', 'safe', 'block', 'compiler' tags to helpers
 - [X] Rename from 'from_file' to 'compile_template_file' and 'from' to 'compile_template'
 - [ ] Write examples, write exsample compiles test
 - [X] Rename from luabars to handlebars
 - [X] Write new main README
 - [ ] Write idempotent optimizations
 - [ ] Write "helper" helper
 - [ ] Write "lua" helper
 - [ ] Write "Include" helper

# Helper definition
```lua
return {
    my_helper = {
        description = [[description of the helper function]],
        stage = "run", -- At what point it will run values = "code_generation", "ast", "run"
        idempotent = false, -- Used for optimizations in the compiler
        unsafe = true, -- If funnction should be available in safe mode
        block = false, -- If it is a block helper
        func = function()
            return ""
        end
    }
}
```
