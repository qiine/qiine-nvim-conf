.DEFAULT_GOAL := run

run:
	nvim

test:
	nvim +checkhealth

lint:
	luacheck lua/

clean:


all: clean lint run

