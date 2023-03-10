TESTS := $(wildcard t/*)
LUA := $(shell find lib/ -type f -name '*.lua')
TESTS_OUT := $(patsubst %, %/output.txt, $(TESTS))


all: test

check: clean-tests $(TESTS_OUT)

t/%/output.txt: t/% handlebars-cli $(LUA) t/%/expected.txt t/%/input.hbs t/%/variables.json
	@ echo $<
	@ ./handlebars-cli --input $</input.hbs \
		        --variables $</variables.json \
			--helpers $</helpers \
		> $@ 2> $</stderr.txt
	@ diff $</expected.txt $@

README.md: README/template.md.hbs README/variables.lua README/helpers.lua
	./handlebars-cli --input $< --variables README/variables.lua > $@

clean-tests:
	rm -f t/*/output.txt
	rm -f t/*/stderr.txt
