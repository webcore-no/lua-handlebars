TESTS := $(wildcard t/*)
LUA := $(shell find lib/ -type f -name '*.lua')
TESTS_OUT := $(patsubst %, %/output.txt, $(TESTS))


all: test

test: $(TESTS_OUT)

t/%/output.txt: t/% luabars-cli $(LUA) t/%/expected.txt t/%/input.hbs t/%/variables.json
	./luabars-cli $</input.hbs $</variables.json > $@ 2> $</stderr.txt
	diff $</expected.txt $@

clean:
	rm t/*/output.txt
	rm t/*/stderr.txt
