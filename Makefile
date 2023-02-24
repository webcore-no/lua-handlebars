TESTS := $(wildcard t/*)
LUA := $(shell find lib/ -type f -name '*.lua')
TESTS_OUT := $(patsubst %, %/output.txt, $(TESTS))


all: test

test: clean-tests $(TESTS_OUT)

t/%/output.txt: t/% luabars-cli $(LUA) t/%/expected.txt t/%/input.hbs t/%/variables.json
	@ echo $<
	@ ./luabars-cli --input $</input.hbs \
		        --variables $</variables.json \
			--helpers $</helpers.lua \
			--inline_helpers $</inline_helpers.lua \
		> $@ 2> $</stderr.txt
	@ diff $</expected.txt $@

README.md: README.md.hbs
	./luabars-cli --input $< > $@

clean-tests:
	rm t/*/output.txt
	rm t/*/stderr.txt
