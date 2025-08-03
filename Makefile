format:
	swift format -ipr Sources/

test:
	swift test --enable-code-coverage

build-docs:
	swift package --allow-writing-to-directory docs \
    	generate-documentation --target App \
    	--disable-indexing \
    	--transform-for-static-hosting \
    	--hosting-base-path swiftodon \
    	--output-path docs

preview-docs:
	swift package --disable-sandbox preview-documentation --target App

.PHONY: format test build-docs preview-docs
