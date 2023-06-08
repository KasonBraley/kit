# MAIN_PACKAGE_PATH := ./cmd/example
# BINARY_NAME := example

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /' | sort

# ==============================================================================
# Install dependencies

## dev-gotooling: install go development dependencies
.PHONY: dev-gotooling
dev-gotooling:
	go install golang.org/x/vuln/cmd/govulncheck@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

# ## build: build the application
# .PHONY: build
# build:
# 	go build -o=/tmp/bin/${BINARY_NAME} ${MAIN_PACKAGE_PATH}
#
# ## run: run the application
# .PHONY: run
# run: build
# 	/tmp/bin/${BINARY_NAME}

## test: run all tests
.PHONY: test
test:
	CGO_ENABLED=0 go test -v -count=1 ./...

## test-race: run all tests with race detection
.PHONY: test-race
test-race:
	CGO_ENABLED=1 go test -v -race -count=1 ./...

## test/cover: run all tests and display coverage
.PHONY: test/cover
test/cover:
	go test -v -buildvcs -coverprofile=/tmp/coverage.out ./...
	go tool cover -html=/tmp/coverage.out

# ==================================================================================== #
# Managing Dependencies
# ==================================================================================== #

## tidy: run `go mod tidy`
.PHONY: tidy
tidy:
	go mod tidy

## deps-reset: reset go.mod
.PHONY: deps-reset
deps-reset:
	git checkout -- go.mod
	go mod tidy

## deps-list: list the dependencies
.PHONY: deps-list
deps-list:
	go list -m -u -mod=readonly all

## deps-upgrade: upgrade all dependencies
.PHONY: deps-upgrade
deps-upgrade:
	go get -u -v ./...
	go mod tidy

## deps-cleancache: clean go.mod cache
.PHONY: deps-cleancache
deps-cleancache:
	go clean -modcache

## deps-verify: verify dependencies
.PHONY: deps-verify
deps-verify:
	go mod verify

## list: list the dependencies
.PHONY: list
list:
	go list -mod=mod all

# ==============================================================================
# Quality Control

## format: format the code
.PHONY: format
format:
	gofmt -w .

## lint: lint the code with golangci-lint
.PHONY: lint
lint:
	golangci-lint run --out-format=tab --sort-results

## vuln-check: check for vulnerabilities
.PHONY: vuln-check
vuln-check:
	govulncheck ./...

## audit: audit the code
.PHONY: audit
audit: deps-verify lint vuln-check test
