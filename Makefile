TOOL = swift run -c release --package-path Tools
PACKAGE = swift package --package-path Tools
SWIFT_FILE_PATHS = Package.swift Sources Tests Examples
TEST_PLATFORM_IOS = iOS Simulator,name=iPhone 13 Pro
TEST_PLATFORM_MACOS = macOS
TEST_PLATFORM_TVOS = tvOS Simulator,name=Apple TV 4K (at 1080p) (2nd generation)
TEST_PLATFORM_WATCHOS = watchOS Simulator,name=Apple Watch Series 7 - 45mm

.PHONY: proj
proj:
	$(TOOL) xcodegen -s Examples/project.yml

.PHONY: format
format:
	$(TOOL) swift-format format -i -p -r $(SWIFT_FILE_PATHS)

.PHONY: lint
lint:
	$(TOOL) swift-format lint -s -p -r $(SWIFT_FILE_PATHS)

.PHONY: test
test: test-library build-examples

.PHONY: test-library
test-library:
	for platform in "$(TEST_PLATFORM_IOS)" "$(TEST_PLATFORM_MACOS)" "$(TEST_PLATFORM_TVOS)" "$(TEST_PLATFORM_WATCHOS)"; do \
	    xcodebuild test -scheme SwiftUI-Hooks -destination platform="$$platform"; \
	done
	cd Examples \
	  && xcodebuild test -scheme Todo-UITests -destination platform="$(TEST_PLATFORM_IOS)" \
	  && xcodebuild test -scheme TheMovieDB-MVVM-Tests -destination platform="$(TEST_PLATFORM_IOS)"

.PHONY: build-examples
build-examples:
	cd Examples && for scheme in "TheMovieDB-MVVM" "BasicUsage" "Todo" ; do \
	    xcodebuild build -scheme "$$scheme" -destination platform="$(TEST_PLATFORM_IOS)"; \
	done
