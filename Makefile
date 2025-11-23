TESTS_INIT=tests/init.lua
TESTS_DIR=tests

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
