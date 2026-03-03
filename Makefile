.PHONY: dev build clean help

# Default target
help:
	@echo "Hugo Blog - Available commands:"
	@echo "  make dev    - Start local development server"
	@echo "  make build  - Build static files to ./public"
	@echo "  make clean  - Remove build artifacts"

# Start local development server with drafts enabled
dev:
	hugo server --buildDrafts --buildFuture --disableFastRender --port 1313

# Build static files for production
build:
	hugo --minify --cleanDestinationDir

# Clean build artifacts
clean:
	rm -rf public resources/_gen
	@echo "Cleaned build artifacts"
