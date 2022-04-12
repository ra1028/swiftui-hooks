.PHONY: format
format:
	@swift run -c release --package-path tools swift-format format -i -p -r Sources Tests Examples
	@swift run -c release --package-path tools xcodegen -s Examples/project.yml

.PHONY: lint
lint:
	@swift run -c release --package-path tools swift-format lint -s -p -r Sources Tests Examples
