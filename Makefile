PROJECT := SwiftMessengerLab.xcodeproj
SCHEME := SwiftMessengerLab
SIMULATOR_NAME ?= iPhone 17 Pro
DESTINATION ?= platform=iOS Simulator,name=$(SIMULATOR_NAME),OS=latest
SIMULATOR_TARGET ?= booted
DERIVED_DATA := .DerivedData
BUNDLE_ID := org.example.SwiftMessengerLab

.PHONY: build test test-ui compiler-lab compiler-test public-scan check run open clean

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

compiler-lab:
	./scripts/compiler-lab.sh '$(SAMPLE)' '$(MODE)'

compiler-test:
	./scripts/compiler-test.sh

public-scan:
	./scripts/public-scan.sh

check: test compiler-test build public-scan

run: build
	xcrun simctl bootstatus '$(SIMULATOR_TARGET)' -b
	xcrun simctl install '$(SIMULATOR_TARGET)' '$(DERIVED_DATA)/Build/Products/Debug-iphonesimulator/SwiftMessengerLab.app'
	xcrun simctl launch --terminate-running-process '$(SIMULATOR_TARGET)' $(BUNDLE_ID)

open:
	open $(PROJECT)

clean:
	rm -rf $(DERIVED_DATA) .build .artifacts
