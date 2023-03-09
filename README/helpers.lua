return {
	gsub = {
		description = "Replaces all occurrences of a pattern in a string with a replacement string.",
		stage = "run",
		idempotent = true,
		block = false,
		func = string.gsub
	}
}
