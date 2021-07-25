.PHONY: format
format:
	@swift run -c release --package-path tools swift-format -i -r -m format --configuration .swift-format.json Sources Tests Examples
	@swift run -c release --package-path tools xcodegen -s Examples/project.yml

.PHONY: lint
lint:
	@swift run -c release --package-path tools swift-format -r -m lint --configuration .swift-format.json Sources Tests Examples
