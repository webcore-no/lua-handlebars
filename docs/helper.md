## idempotent
A idempotent helper is a helper that can be called multiple times without changing the result of the first call.
For example, the `{{#each}}` helper is idempotent because it can be called multiple times with the same input and the same output will be produced each time.

## block
A block helper is a helper that has a start and a end tag.

## unsafe
An unsafe helper is a helper that might perform unsafe operations, such as running arbitrary lua code, so only use it if you trust the input.
