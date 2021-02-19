.PHONY: proj
proj:
	@swift run -c release --package-path tools xcodegen

.PHONY: fmt
fmt:
	@swift run -c release --package-path tools swift-format -i -r -m format --configuration .swift-format.json Sources Tests Examples

.PHONY: lint
lint:
	@swift run -c release --package-path tools swift-format -r -m lint --configuration .swift-format.json Sources Tests Examples
