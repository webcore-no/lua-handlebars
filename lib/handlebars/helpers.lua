local util = require("lib.handlebars.util")


--my_helper = {
--    description = [[description of the helper function]],
--    stage = "run", -- At what point it will run values = "code_generation", "ast", "run"
--    idempotent = false, -- Used for optimizations in the compiler
--    unsafe = true, -- If funnction should be available in safe mode
--    block = false, -- If it is a block helper
--    func = function()
--        return ""
--    end
--}
local _M = {}

_M.log = {
	description = "Log to stdout",
	stage = "run",
	idempotent = false,
	block = false,
	func = function(...)
		util.err_printf(...)
	end
}

_M.err_log = {
	description = "Log to stderr",
	stage = "run",
	idempotent = false,
	block = false,
	func = function(...)
		util.printf(...)
	end
}

_M["if"] = {
	description = "If block",
	stage = "code_generation",
	idempotent = true,
	block = true,
	func = function(self, token)
		if #(token.params) ~= 1 then
			return nil, "#if requires exactly one argument"
		end
		local cond, err = self:resolve_param(token.params[1])
		if not cond then
			return nil, err
		end

		self:scope_up("if %s then", cond)
		if token.children then
			for _, v in ipairs(token.children) do
				err = self:generate_code(v)
				if err then
					return err
				end
			end
		end
		if token.inverse then
			self:scope_else()
			if token.inverse.children then
				for _, v in ipairs(token.inverse.children) do
					err = self:generate_code(v)
					if err then
						return nil, err
					end
				end
			end
		end
		self:scope_down()
		return ''
	end
}

_M.unless = {
	description = "Unless block",
	stage = "code_generation",
	idempotent = true,
	block = true,
	func = function(self, token)
		if #(token.params) ~= 1 then
			return nil, "#unless requires exactly one argument"
		end
		local cond, err = self:resolve_param(token.params[1])
		if not cond then
			return nil, err
		end

		self:scope_up("if not (%s) then", cond)
		if token.children then
			for _, v in ipairs(token.children) do
				err = self:generate_code(v)
				if err then
					return err
				end
			end
		end
		if token.inverse then
			self:scope_else()
			if token.inverse.children then
				for _, v in ipairs(token.inverse.children) do
					err = self:generate_code(v)
					if err then
						return nil, err
					end
				end
			end
		end
		self:scope_down()
		return ''
	end
}

_M.each = {
	description = "Each block",
	stage = "code_generation",
	idempotent = true,
	block = true,
	func = function(self, token)
		if #(token.params) ~= 1 then
			return nil, "#each requires exactly one argument"
		end
		local param, err = self:resolve_param(token.params[1])
		if not param then
			return nil, err
		end
		self:emit("local arr = %s or {}", param)
		self:scope_up("for key, self in pairs(arr) do")
		self:emit("local index = key", param)

		local path = self:_resolve_path(token.params[1])
		path[#path+1] = { type="array", value="key" }
		self:self_push(path)

		if token.children then
			for _, v in ipairs(token.children) do
				err = self:generate_code(v)
				if err then
					return nil, err
				end
			end
		end
		if token.inverse then
			self:self_pop()
			path[#path] = nil
			self:self_push(path)
			self:scope_down()
			self:scope_up("if #(arr) and not next(arr) then")
			if token.inverse.children then
				for _, v in ipairs(token.inverse.children) do
					err = self:generate_code(v)
					if err then
						return nil, err
					end
				end
			end
		end
		self:self_pop()
		self:scope_down()
		return ''
	end
}

_M.gmatch = {
	description = "Iterate trough a matches of a pattern see lua patterns",
	stage = "code_generation",
	idempotent = true,
	block = true,
	func = function(self, token)
		local pattern, string, gmatch, path, err
		if #(token.params) ~= 2 then
			return nil, "#each requires exactly two argument"
		end
		string, err = self:resolve_param(token.params[1])
		if not string then
			return nil, err
		end

		pattern, err = self:resolve_param(token.params[2])
		if not pattern then
			return nil, err
		end
		gmatch = self:define("string.gmatch")
		self:scope_up("for match in %s(%s, %s) do", gmatch, string, pattern)

		path = {{ type="path", value="match" }}
		self:self_push(path)

		if token.children then
			for _, v in ipairs(token.children) do
				err = self:generate_code(v)
				if err then
					return nil, err
				end
			end
		end
		self:self_pop()
		self:scope_down()
		return ''
	end
}

_M.with = {
	description = "With block",
	stage = "code_generation",
	idempotent = true,
	block = true,
	func = function(self, token)
		if #(token.params) ~= 1 then
			return nil, "#with requires exactly one arguments"
		end
		local param, err = self:resolve_param(token.params[1])
		if not param then
			return nil, err
		end
		self:scope_up("do", param)
		local path = self:_resolve_path(token.params[1])
		self:self_push(path)
		if token.children then
			for _, v in ipairs(token.children) do
				err = self:generate_code(v)
				if err then
					return nil, err
				end
			end
		end
		self:self_pop()
		self:scope_down()
		return ''
	end
}

_M.format = {
	description = "format string",
	stage = "run",
	idempotent = true,
	block = false,
	func = string.format
}

_M.sub = {
	description = "Extract substring",
	stage = "run",
	idempotent = true,
	block = false,
	func = string.sub
}

_M.upper = {
	description = "Uppercase string",
	stage = "run",
	idempotent = true,
	block = false,
	func = string.upper
}

_M.lower = {
	description = "Lowercase string",
	stage = "run",
	idempotent = true,
	block = false,
	func = string.lower
}

_M.gsub = {
		description = "Replaces all occurrences of a pattern in a string with a replacement string.",
		stage = "run",
		idempotent = true,
		block = false,
		func = string.gsub
}
return _M
