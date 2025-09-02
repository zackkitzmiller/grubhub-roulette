# Project Justfile
# Just is a command runner - https://github.com/casey/just

# Default target
default:
    @just --list

# Build the project
build:
    cargo build

# Build release version
release:
    cargo build --release

# Check for compilation errors
check:
    cargo check

# Run tests
test:
    cargo test

# Run tests with output
test-verbose:
    cargo test -- --nocapture

# Run clippy linter
clippy:
    cargo clippy

# Run clippy with all warnings
clippy-strict:
    cargo clippy -- -D warnings

# Format code
fmt:
    cargo fmt

# Check formatting
fmt-check:
    cargo fmt -- --check

# Clean build artifacts
clean:
    cargo clean

# Install the binary globally
install:
    cargo install --path .

# Uninstall the binary
uninstall:
    cargo uninstall

# Show help
help:
    @just --list

# Test all features
test-all: check test clippy fmt-check

# Prepare for release
prepare-release: test-all release

# Generate documentation
doc:
    cargo doc --open

# Check for security vulnerabilities
audit:
    cargo audit

# Update dependencies
update:
    cargo update

# Show outdated dependencies
outdated:
    cargo outdated

# Install development tools
install-tools:
    cargo install cargo-audit
    cargo install cargo-outdated
    cargo install cargo-watch

# Watch for changes and run tests
watch:
    cargo watch -x check -x test

# Run with cargo watch
dev:
    cargo watch -x run

# Show project info
info:
    @echo "Project Information"
    @echo "=================="
    @echo "Just version: $(just --version)"
    @echo "Cargo version: $(cargo --version)"
    @echo "Rust version: $(rustc --version)"
