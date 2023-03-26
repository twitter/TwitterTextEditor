# Copyright 2021 Twitter, Inc.
# SPDX-License-Identifier: Apache-2.0

NAME = TwitterTextEditor

BUILD_SCHEME = $(NAME)-Package
BUILD_DESTINATION = generic/platform=iOS
BUILD_CONFIGURATION = Debug
BUILD_DERIVED_DATA_PATH = .build/derived_data

# Use `xcodebuild -showdestinations -scheme ...` for the destinations.
# See also <https://github.com/actions/runner-images/blob/main/images/macos/macos-12-Readme.md>
# for commonly available destinations.
TEST_DESTINATION = platform=iOS Simulator,name=iPhone 14

# This path depends on `BUILD_DESTINATION`.
DOCBUILD_DOCARCHIVE_PATH = $(BUILD_DERIVED_DATA_PATH)/Build/Products/$(BUILD_CONFIGURATION)-iphoneos/$(NAME).doccarchive

GITHUB_REPOSITORY_NAME = $(NAME)
GITHUB_PAGES_PATH ?= .gh-pages

DOCUMENTATION_SERVER_ROOT_PATH = .build/documentation
DOCUMENTATION_SERVER_PORT = 3000
# This is simulating how GitHub pages URL is represented, which is `https://$(USERNAME).github.io/$(REPOSITORY_NAME)/`.
DOCUMENTATION_OUTPUT_PATH = $(DOCUMENTATION_SERVER_ROOT_PATH)/$(GITHUB_REPOSITORY_NAME)
DOCUMENTATION_ROOT_TARGET_NAME = twittertexteditor

XCODEBUILD = xcodebuild
DOCC = xcrun docc
PYTHON3 = xcrun python3
SWIFT = swift
SWIFTLINT = swiftlint

.PHONY: all
all: fix test

.PHONY: clean
clean:
	git clean -dfX

.PHONY: fix
fix:
	$(SWIFTLINT) --fix

.PHONY: lint
lint:
	$(SWIFTLINT) --strict

.PHONY: build
build:
	$(XCODEBUILD) \
		-scheme "$(BUILD_SCHEME)" \
		-destination "$(BUILD_DESTINATION)" \
		-configuration "$(BUILD_CONFIGURATION)" \
		-derivedDataPath "$(BUILD_DERIVED_DATA_PATH)" \
		build

.PHONY: test
test:
	$(XCODEBUILD) \
		-scheme "$(BUILD_SCHEME)" \
		-destination "$(TEST_DESTINATION)" \
		-configuration "$(BUILD_CONFIGURATION)" \
		-derivedDataPath "$(BUILD_DERIVED_DATA_PATH)" \
		test

.PHONY: docbuild
docbuild:
	$(XCODEBUILD) \
		-scheme "$(BUILD_SCHEME)" \
		-destination "$(BUILD_DESTINATION)" \
		-configuration "$(BUILD_CONFIGURATION)" \
		-derivedDataPath "$(BUILD_DERIVED_DATA_PATH)" \
		docbuild

.PHONY: doc
doc: docbuild
	mkdir -p "$(DOCUMENTATION_OUTPUT_PATH)"
	$(DOCC) process-archive transform-for-static-hosting "$(DOCBUILD_DOCARCHIVE_PATH)" \
		--output-path "$(DOCUMENTATION_OUTPUT_PATH)" \
		--hosting-base-path "/$(GITHUB_REPOSITORY_NAME)"

.PHONY: doc-server
doc-server: doc
	@echo "Documentation is available at <http://localhost:$(DOCUMENTATION_SERVER_PORT)/$(GITHUB_REPOSITORY_NAME)/documentation/$(DOCUMENTATION_ROOT_TARGET_NAME)>"
	$(PYTHON3) -m http.server --directory "$(DOCUMENTATION_SERVER_ROOT_PATH)" $(DOCUMENTATION_SERVER_PORT)

.PHONY: ghpages
ghpages: doc
	mkdir -p "$(GITHUB_PAGES_PATH)"
	rsync -av8  --exclude .git --delete "$(DOCUMENTATION_OUTPUT_PATH)"/ "$(GITHUB_PAGES_PATH)"/
