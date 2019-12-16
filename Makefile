## This Makefile is meant to be run on Unix hosts - as such, it only supports the few
## operations that don't require on a Windows host, mostly code generation and linting.

.DEFAULT_GOAL := all
SHELL := /bin/bash

ifeq ($(GOPATH),)
$(error "GOPATH env variable not defined")
endif

REPO_ROOT = $(CURDIR)
BUILD_DIR = build
BUILD_TOOLS_DIR = $(BUILD_DIR)/tools

GO_ENV_VARS = GO111MODULE=on GOOS=windows

.PHONY: all
all: generate compile lint

.PHONY: compile
compile: compile-client compile-server compile-csi-proxy-api-gen

.PHONY: compile-client
compile-client:
	cd client && $(GO_ENV_VARS) go build ./...

.PHONY: compile-server
compile-server:
	$(GO_ENV_VARS) go build -o $(BUILD_DIR)/server.exe ./cmd/server

CSI_PROXY_API_GEN = $(BUILD_DIR)/csi-proxy-api-gen

.PHONY: compile-csi-proxy-api-gen
compile-csi-proxy-api-gen:
	GO111MODULE=on go build -o $(CSI_PROXY_API_GEN) ./cmd/csi-proxy-api-gen

.PHONY: generate
generate: generate-protobuf generate-csi-proxy-api-gen

# using xargs instead of -exec since the latter doesn't propagate exit statuses
.PHONY: generate-protobuf
generate-protobuf:
	@ if ! which protoc > /dev/null 2>&1; then echo 'Unable to find protoc binary' ; exit 1; fi
	@ generate_protobuf_for() { \
		local FILE="$$1"; \
		local FILE_DIR="$$(dirname "$$FILE")"; \
		echo "Generating protobuf file from $$FILE"; \
		protoc -I "$$FILE_DIR" -I "$$GOPATH/src" -I '$(REPO_ROOT)/client/api' "$$FILE" --go_out=plugins="grpc:$$FILE_DIR"; \
	} ; \
	export -f generate_protobuf_for; \
	find '$(REPO_ROOT)' -name '*.proto' -print0 | xargs -0 -n1 $(SHELL) -c 'generate_protobuf_for "$$0"'

.PHONY: generate-csi-proxy-api-gen
generate-csi-proxy-api-gen: compile-csi-proxy-api-gen
	$(CSI_PROXY_API_GEN) -i github.com/kubernetes-csi/csi-proxy/client/api,github.com/kubernetes-csi/csi-proxy/integrationtests/apigroups/api/dummy

.PHONY: clean
clean: clean-protobuf clean-generated

.PHONY: clean-protobuf
clean-protobuf:
	find '$(REPO_ROOT)' -name '*.proto' -exec $(SHELL) -c 'rm -vf "$$(dirname {})/$$(basename {} .proto).pb.go"' \;

.PHONY: clean-generated
clean-generated:
	find '$(REPO_ROOT)' -name '*_generated.go' -exec $(SHELL) -c '[[ "$$(head -n 1 "{}")" == "// Code generated by csi-proxy-api-gen"* ]] && rm -v {}' \;

# see https://github.com/golangci/golangci-lint/releases
GOLANGCI_LINT_VERSION = v1.21.0
GOLANGCI_LINT = $(BUILD_TOOLS_DIR)/golangci-lint/$(GOLANGCI_LINT_VERSION)/golangci-lint

.PHONY: lint
lint: $(GOLANGCI_LINT)
	$(GO_ENV_VARS) $(GOLANGCI_LINT) run
	git --no-pager diff --exit-code

# see https://github.com/golangci/golangci-lint#binary-release
$(GOLANGCI_LINT):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$$(dirname '$(GOLANGCI_LINT)')" '$(GOLANGCI_LINT_VERSION)'