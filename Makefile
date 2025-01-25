format:
	swift format -ipr Sources/

test:
	swift test --enable-code-coverage

.PHONY: format test
