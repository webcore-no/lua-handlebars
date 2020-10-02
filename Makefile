TESTS := $(wildcard t/*)
LUA := $(shell find lib/ -type f -name '*.lua')

all: test

test: $(TESTS)/output.txt
	echo $(TESTS)

t/%/output.txt: t/% luabars-cli $(LUA) t/%/expected.txt t/%/input.hbs t/%/variables.json
	./luabars-cli $</input.hbs $</variables.json > $@ 2> $</stderr.txt
	diff $</expected.txt $@

clean:
	rm t/*/output.txt
	rm t/*/stderr.txt
