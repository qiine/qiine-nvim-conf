.DEFAULT_GOAL := run

run:
	nvim
test:
	nvim +checkhealth
clean:

all: clean run

