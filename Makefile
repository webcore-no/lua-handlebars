TESTS = $(wildcard t/*)
LUA = $(shell find lib/ -type f -name '*.lua')

all: test

test: $(TESTS)/output.txt
	echo $(LUA)


t/%/output.txt: t/% luabars-cli $(LUA) t/%/expected.txt t/%/input.handlebars t/%/variables.json
	./luabars-cli $</input.handlebars $</variables.json > $@
	diff $</expected.txt $@

clean:
	rm t/*/output.txt
