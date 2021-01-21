NAME = TwitterTextEditor

BUILD_PROJECT = $(NAME).xcodeproj
BUILD_SCHEME = $(NAME)-Package
BUILD_SDK = iphonesimulator
BUILD_DERIVED_DATA_PATH = .build/derived_data

# Use `use `xcodebuild -showdestinations -scheme ...` for the destinations.
# See also <https://github.com/actions/virtual-environments/blob/main/images/macos/macos-10.15-Readme.md>
# for commonly available destinations.
TEST_DESTINATION = platform=iOS Simulator,name=iPhone 11

DOCUMENTATION_SOURCE_FILES = Sources/*/*.swift
DOCUMENTATION_SUPPLIMENT_FILES = Resources/Documentation/*.md
DOCUMENTATION_OUTPUT_PATH = .build/documentation

GITHUB_PAGES_PATH ?= .gh-pages
GITHUB_PAGES_DOCUMENTATION_PATH = $(GITHUB_PAGES_PATH)/doc

XCODEBUILD = xcodebuild
SWIFT = swift
SWIFTLINT = swiftlint

RUBY_BIN_PATH = /usr/bin
RUBY = $(RUBY_BIN_PATH)/ruby
BUNDLE = $(RUBY_BIN_PATH)/bundle

.PHONY: all
all: correct test

.PHONY: clean
clean:
	git clean -dfX

.bundle: Gemfile
	$(BUNDLE) install --path "$@"
	touch "$@"

.PHONY: bundle
bundle: .bundle

.PHONY: correct
correct: .bundle
	$(SWIFTLINT) autocorrect
	$(BUNDLE) exec rubocop --auto-correct-all

.PHONY: lint
lint: .bundle
	$(SWIFTLINT)
	$(BUNDLE) exec rubocop

$(BUILD_PROJECT): Package.swift Sources/**/* Tests/**/*
	$(SWIFT) package generate-xcodeproj
	touch "$@"

.PHONY: build
build: $(BUILD_PROJECT)
	$(XCODEBUILD) \
		-project "$<" \
		-scheme "$(BUILD_SCHEME)" \
		-derivedDataPath "$(BUILD_DERIVED_DATA_PATH)" \
		-sdk "$(BUILD_SDK)" \
		build

.PHONY: test
test: $(BUILD_PROJECT)
	$(XCODEBUILD) \
		-project "$<" \
		-scheme "$(BUILD_SCHEME)" \
		-derivedDataPath "$(BUILD_DERIVED_DATA_PATH)" \
		-destination "$(TEST_DESTINATION)" \
		test

# NOTE: Double quote for `--include` is important to let Jazzy exapand the wildcard.
$(DOCUMENTATION_OUTPUT_PATH): .bundle .jazzy.yaml $(BUILD_PROJECT) $(DOCUMENTATION_SUPPLIMENT_FILES) $(DOCUMENTATION_SOURCE_FILES)
	mkdir -p "$@"
	$(BUNDLE) exec jazzy \
		--output "$@" \
		--clean \
		--module $(NAME) \
		--use-safe-filenames \
		--build-tool-arguments "-project,$(BUILD_PROJECT),-scheme,$(BUILD_SCHEME),-sdk,$(BUILD_SDK),-derivedDataPath,$(BUILD_DERIVED_DATA_PATH)" \
		--include "$(DOCUMENTATION_SOURCE_FILES)"

.PHONY: doc
doc: $(DOCUMENTATION_OUTPUT_PATH)

.PHONY: doc-server
doc-server: .bundle doc
	@$(BUNDLE) exec $(RUBY) Scripts/docserver.rb \
		-d "$(DOCUMENTATION_OUTPUT_PATH)" \
		-c "make doc" \
		$(DOCUMENTATION_SUPPLIMENT_FILES) \
		$(DOCUMENTATION_SOURCE_FILES)

$(GITHUB_PAGES_DOCUMENTATION_PATH): $(DOCUMENTATION_OUTPUT_PATH)
	mkdir -p "$@"
	rsync -av8 --exclude .git --exclude docsets --delete "$<"/ "$@"/

.PHONY: ghpages
ghpages: $(GITHUB_PAGES_DOCUMENTATION_PATH)
