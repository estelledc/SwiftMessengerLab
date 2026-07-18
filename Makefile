PROJECT := SwiftMessengerLab.xcodeproj
SCHEME := SwiftMessengerLab
SIMULATOR_NAME ?= iPhone 17 Pro
SIMULATOR_OS ?= $(shell xcrun --sdk iphonesimulator --show-sdk-version)
DESTINATION ?= generic/platform=iOS Simulator
UI_DESTINATION ?= platform=iOS Simulator,name=$(SIMULATOR_NAME),OS=$(SIMULATOR_OS)
SIMULATOR_UDID ?= $(shell xcrun simctl list devices available 2>/dev/null | awk -v runtime="-- iOS $(SIMULATOR_OS) --" -v device="$(SIMULATOR_NAME)" '\
	$$0 == runtime { in_runtime = 1; next } \
	in_runtime && /^-- / { exit } \
	in_runtime { \
		line = $$0; sub(/^[[:space:]]*/, "", line); prefix = device " ("; \
		if (index(line, prefix) == 1) { \
			line = substr(line, length(prefix) + 1); print substr(line, 1, index(line, ")") - 1); exit \
		} \
	}')
SIMULATOR_TARGET ?= $(SIMULATOR_UDID)
DERIVED_DATA := .DerivedData
BUNDLE_ID := io.github.estelledc.SwiftMessengerLab
APP_ARGUMENTS ?=
CONFIGURATION ?= Debug

.PHONY: prepare-local-caches build build-release test test-ui type-cards verify-type-cards experiment-cards verify-experiment-cards compiler-lab compiler-test audit-project verify-showcase public-scan check release-check run run-fresh open clean

SAMPLE ?= property-access
MODE ?= debug

prepare-local-caches:
	@root=$$(pwd -P); \
	for directory in .build $(DERIVED_DATA); do \
		marker="$$directory/.swiftmessengerlab-workspace-root"; \
		if [ -d "$$directory" ] && { [ ! -f "$$marker" ] || [ "$$(cat "$$marker")" != "$$root" ]; }; then \
			echo "Resetting relocated build cache: $$directory"; \
			rm -rf "$$directory"; \
		fi; \
		mkdir -p "$$directory"; \
		printf '%s\n' "$$root" > "$$marker"; \
	done

build: prepare-local-caches
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-sdk iphonesimulator \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED_DATA) \
		CODE_SIGNING_ALLOWED=NO \
		build

build-release:
	$(MAKE) build CONFIGURATION=Release

test: prepare-local-caches
	swift test

test-ui: prepare-local-caches
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(UI_DESTINATION)' \
		-derivedDataPath $(DERIVED_DATA) \
		CODE_SIGNING_ALLOWED=NO \
		test

type-cards: prepare-local-caches
	swift run type-catalog-exporter

verify-type-cards: prepare-local-caches
	swift run type-catalog-exporter --check

experiment-cards: prepare-local-caches
	swift run experiment-card-exporter

verify-experiment-cards: prepare-local-caches
	swift run experiment-card-exporter --check

compiler-lab:
	./scripts/compiler-lab.sh '$(SAMPLE)' '$(MODE)'

compiler-test:
	./scripts/compiler-test.sh

audit-project:
	python3 scripts/audit-project.py

verify-showcase:
	./scripts/verify-showcase.sh

public-scan:
	./scripts/public-scan.sh

check: test verify-type-cards verify-experiment-cards compiler-test audit-project build verify-showcase public-scan

release-check: test test-ui verify-type-cards verify-experiment-cards compiler-test audit-project build-release verify-showcase public-scan

run: build
	@test -n "$(SIMULATOR_TARGET)" || { echo "No available $(SIMULATOR_NAME) with iOS $(SIMULATOR_OS)" >&2; exit 2; }
	@xcrun simctl boot '$(SIMULATOR_TARGET)' >/dev/null 2>&1 || true
	xcrun simctl bootstatus '$(SIMULATOR_TARGET)' -b
	xcrun simctl install '$(SIMULATOR_TARGET)' '$(DERIVED_DATA)/Build/Products/$(CONFIGURATION)-iphonesimulator/SwiftMessengerLab.app'
	xcrun simctl launch --terminate-running-process '$(SIMULATOR_TARGET)' $(BUNDLE_ID) $(APP_ARGUMENTS)

run-fresh:
	$(MAKE) run APP_ARGUMENTS='--reset-cache --reset-learning-progress'

open:
	open $(PROJECT)

clean:
	rm -rf $(DERIVED_DATA) .build .artifacts
