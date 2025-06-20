default: help

.PHONY: help
help: # show help for each of the Makefile recipes
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

cicd: # run the CI/CD workflow locally.
	act -P ubuntu-24.04=ghcr.io/catthehacker/ubuntu:act-latest \
		--artifact-server-path $$PWD/.artifacts

.PHONY: check-tokens
check-tokens: # check the tokens in each file used by AI
	pip install tabulate
	python .github/scripts/check_tokens.py

.PHONY: site-build
site-build: # build the the MCP server site
	mkdir -p ./site
	python .github/scripts/generate_json.py README.md ./site

.PHONY: site-run
site-run: site-build # run a simple HTTP server for the site
	@echo "Starting HTTP server at http://localhost:9090"
	@echo "Press Ctrl+C to stop the server"
	python -m http.server --directory ./site 9090

.PHONY: site-dev
site-dev: # run development server with live reload and auto-rebuild
	@echo "Installing development dependencies..."
	@pip install watchdog > /dev/null 2>&1 || (echo "Installing watchdog..." && pip install watchdog)
	@mkdir -p ./site
	python .github/scripts/dev_server.py README.md ./site