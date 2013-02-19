
BIN = ./node_modules/.bin
TEST_OPTS = --timeout 200 --slow 100 --reporter spec --compilers coffee:coffee-script --globals __coverage__ --bail
COMPILE_OPTS = --compile --bare

default: test

clean:
	rm -Rf lib-cov
	rm -Rf coverage
	rm -Rf html-report

node_modules:
	npm install

lib/%.js: node_modules src/%.coffee
	@$(BIN)/coffee $(COMPILE_OPTS) --output $(@D) $<
watch: node_modules
	@$(BIN)/coffee $(COMPILE_OPTS) --watch --output lib/timer-shim.js src/timer-shim.coffee

test: node_modules
	@$(BIN)/mocha $(TEST_OPTS) test/timer-shim.coffee
tdd: node_modules
	@$(BIN)/mocha $(TEST_OPTS) --watch test/timer-shim.coffee

cover: instrument
	@echo open html-report/index.html to view coverage report.
	@COVER=1 $(BIN)/mocha $(TEST_OPTS) --reporter mocha-istanbul test/timer-shim.coffee

instrument: node_modules lib/timer-shim.js
	@mkdir -p lib-cov/
	@$(BIN)/istanbul instrument --variable global.__coverage__ --output lib-cov/timer-shim.js --no-compact lib/timer-shim.js

.PHONY: instrument all default test tdd cover clean watch

