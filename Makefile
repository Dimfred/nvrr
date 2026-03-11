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
# HELP
help: ## print this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
