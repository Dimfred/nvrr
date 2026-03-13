.ONESHELL:
SHELL := /bin/bash
all: help

################################################################################
# PROJECT CONFIG
PROJECT_NAME := nvrr

################################################################################
# APP
build: ## build the project
	cargo build

build-release: ## build the project in release mode
	cargo build --release

build-macos: ## cross-compile for macOS (arm64)
	cargo build --release --target aarch64-apple-darwin

build-linux: ## cross-compile for Linux (x86_64)
	cargo zigbuild --release --target x86_64-unknown-linux-gnu

build-windows: ## cross-compile for Windows (x86_64)
	cargo zigbuild --release --target x86_64-pc-windows-gnu

run: ## run the project
	cargo run

clean: ## clean build artifacts
	cargo clean

################################################################################
# TEST
test: ## run all tests
	cargo test

test-verbose: ## run all tests with verbose output
	cargo test -- --nocapture

################################################################################
# LINT
lint: ## run clippy linter
	cargo clippy -- -D warnings

fmt: ## format code
	cargo fmt

fmt-check: ## check code formatting
	cargo fmt -- --check

check: fmt-check lint test ## run all checks (fmt, lint, test)

################################################################################
# INSTALL
install: ## install the binary locally
	cargo install --path .

################################################################################
# RELEASE
github-release: build-macos build-linux build-windows ## create GitHub release with all platform binaries
	@VERSION=$$(grep -m1 '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'); \
	mkdir -p releases; \
	cp target/aarch64-apple-darwin/release/$(PROJECT_NAME) "releases/$(PROJECT_NAME)-v$${VERSION}-macos-arm64"; \
	cp target/x86_64-unknown-linux-gnu/release/$(PROJECT_NAME) "releases/$(PROJECT_NAME)-v$${VERSION}-linux-x86_64"; \
	cp target/x86_64-pc-windows-gnu/release/$(PROJECT_NAME).exe "releases/$(PROJECT_NAME)-v$${VERSION}-windows-x86_64.exe"; \
	echo "Binaries copied to releases/"; \
	if gh release view "v$$VERSION" >/dev/null 2>&1; then \
		echo "Release v$$VERSION already exists"; \
		read -p "Delete and recreate? [y/N] " -n 1 -r; \
		echo; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			gh release delete "v$$VERSION" -y; \
		else \
			exit 1; \
		fi; \
	fi; \
	gh release create "v$$VERSION" \
		"releases/$(PROJECT_NAME)-v$${VERSION}-macos-arm64" \
		"releases/$(PROJECT_NAME)-v$${VERSION}-linux-x86_64" \
		"releases/$(PROJECT_NAME)-v$${VERSION}-windows-x86_64.exe" \
		--title "v$$VERSION" \
		--notes "$(PROJECT_NAME) v$$VERSION" \
		--latest; \
	echo "Released v$$VERSION"

cargo-publish: ## publish to crates.io
	cargo publish

release: github-release cargo-publish ## create GitHub release, publish to crates.io, and update brew formula
	@$(MAKE) brew-update
	@VERSION=$$(grep -m1 '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'); \
	git add Formula/$(PROJECT_NAME).rb; \
	git commit -m "chore: formula update"; \
	git push; \
	echo "Committed and pushed formula update"

version-patch: ## bump patch version (0.1.0 -> 0.1.1)
	@CURRENT=$$(grep -m1 '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'); \
	IFS='.' read -r MAJOR MINOR PATCH <<< "$$CURRENT"; \
	NEW_PATCH=$$((PATCH + 1)); \
	NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH"; \
	sed -i '' "s/^version = \".*\"/version = \"$$NEW_VERSION\"/" Cargo.toml; \
	echo "Version bumped from $$CURRENT to $$NEW_VERSION"; \
	git add Cargo.toml; \
	git commit -m "chore: version bump"; \
	echo "Committed version bump"

################################################################################
# BREW
brew-update: ## update brew formula and push to homebrew-tap
	@VERSION=$$(grep -m1 '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'); \
	URL="https://github.com/Dimfred/$(PROJECT_NAME)/archive/refs/tags/v$${VERSION}.tar.gz"; \
	echo "Fetching $$URL"; \
	SHA=$$(curl -sL "$$URL" | shasum -a 256 | cut -d' ' -f1); \
	echo "SHA256: $$SHA"; \
	sed -i '' "s|url \".*\"|url \"$$URL\"|" Formula/$(PROJECT_NAME).rb; \
	sed -i '' "s|sha256 \".*\"|sha256 \"$$SHA\"|" Formula/$(PROJECT_NAME).rb; \
	echo "Formula updated for v$$VERSION"; \
	cp Formula/$(PROJECT_NAME).rb ../homebrew-tap/Formula/; \
	cd ../homebrew-tap && git add . && git commit -m "Update $(PROJECT_NAME) to v$$VERSION" && git push; \
	echo "Pushed to homebrew-tap"

################################################################################
# INIT
init: ## initialize dev environment (rust targets, zigbuild)
	brew install zig@0.14
	rustup target add aarch64-apple-darwin x86_64-unknown-linux-gnu x86_64-pc-windows-gnu
	cargo install cargo-zigbuild

################################################################################
# HELP
help: ## print this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
