
BIN = ./node_modules/.bin
TEST_OPTS = --timeout 200 --slow 100 --reporter spec --compilers coffee:coffee-script --globals __coverage__ --bail
COMPILE_OPTS = --compile --bare

TEST_FILES := $(wildcard test/*.coffee)

default: test

clean:
	rm -Rf lib-cov
	rm -Rf coverage
	rm -Rf html-report

node_modules:
	npm install

all: lib/timer-shim.js

lib/%.js: node_modules
lib/%.js: src/%.coffee
	@$(BIN)/coffee $(COMPILE_OPTS) --output $(@D) $<
watch: node_modules
	@$(BIN)/coffee $(COMPILE_OPTS) --watch --output lib/timer-shim.js src/timer-shim.coffee

test: node_modules
	@$(BIN)/mocha $(TEST_OPTS) $(TEST_FILES)
tdd: node_modules
	@$(BIN)/mocha $(TEST_OPTS) --watch $(TEST_FILES)

cover: instrument
	@echo open html-report/index.html to view coverage report.
	@COVER=1 $(BIN)/mocha $(TEST_OPTS) --reporter mocha-istanbul $(TEST_FILES)

instrument: node_modules lib/timer-shim.js
	@mkdir -p lib-cov/
	@$(BIN)/istanbul instrument --variable global.__coverage__ --output lib-cov/timer-shim.js --no-compact lib/timer-shim.js

.PHONY: instrument all default test tdd cover clean watch

