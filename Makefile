
BIN = ./node_modules/.bin
TEST_OPTS = --timeout 200 --slow 100 --reporter spec --compilers coffee:coffee-script --globals __coverage__
COMPILE_OPTS = --bare

default: test

clean:
	rm -Rf lib-cov
	rm -Rf coverage
	rm -Rf html-report

lib/%.js: src/%.coffee
	@$(BIN)/coffee $(COMPILE_OPTS) --compile --output $(@D) $<
watch:
	@$(BIN)/coffee $(COMPILE_OPTS) --compile --watch --output lib/timer-shim.js src/timer-shim.coffee

test:
	@$(BIN)/mocha $(TEST_OPTS) test/timer-shim.coffee
tdd:
	@$(BIN)/mocha $(TEST_OPTS) --watch test/timer-shim.coffee

cover: instrument
	@echo open html-report/index.html to view coverage report.
	@COVER=1 $(BIN)/mocha $(TEST_OPTS) --reporter mocha-istanbul test/timer-shim.coffee

instrument: lib/timer-shim.js
	@mkdir -p lib-cov/
	@$(BIN)/istanbul instrument --variable global.__coverage__ --output lib-cov/timer-shim.js --no-compact lib/timer-shim.js

.PHONY: instrument all default test tdd cover clean watch

