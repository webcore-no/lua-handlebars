FOLDER=$(PWD)

all: README.md


README.md: README.md.hbs README.lua *.lua
	cd ../ && ./handlebars-cli --input $(FOLDER)/$< --variables $(FOLDER)/README.lua > $(FOLDER)/$@
