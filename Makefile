PROJECT := SwiftMessengerLab.xcodeproj
SCHEME := SwiftMessengerLab
SIMULATOR_NAME ?= iPhone 17 Pro
DESTINATION ?= platform=iOS Simulator,name=$(SIMULATOR_NAME),OS=latest
SIMULATOR_TARGET ?= booted
DERIVED_DATA := .DerivedData
BUNDLE_ID := io.github.estelledc.SwiftMessengerLab

.PHONY: build test test-ui type-cards verify-type-cards compiler-lab compiler-test verify-showcase public-scan check release-check run open clean

SAMPLE ?= property-access
MODE ?= debug

build:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-sdk iphonesimulator \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED_DATA) \
		CODE_SIGNING_ALLOWED=NO \
		build

test:
	swift test

test-ui:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED_DATA) \
		CODE_SIGNING_ALLOWED=NO \
		test

type-cards:
	swift run type-catalog-exporter

verify-type-cards:
	swift run type-catalog-exporter --check

compiler-lab:
	./scripts/compiler-lab.sh '$(SAMPLE)' '$(MODE)'

compiler-test:
	./scripts/compiler-test.sh

verify-showcase:
	./scripts/verify-showcase.sh

public-scan:
	./scripts/public-scan.sh

check: test verify-type-cards compiler-test build verify-showcase public-scan

release-check: test test-ui verify-type-cards compiler-test build verify-showcase public-scan

run: build
	xcrun simctl bootstatus '$(SIMULATOR_TARGET)' -b
	xcrun simctl install '$(SIMULATOR_TARGET)' '$(DERIVED_DATA)/Build/Products/Debug-iphonesimulator/SwiftMessengerLab.app'
	xcrun simctl launch --terminate-running-process '$(SIMULATOR_TARGET)' $(BUNDLE_ID)

open:
	open $(PROJECT)

clean:
	rm -rf $(DERIVED_DATA) .build .artifacts
