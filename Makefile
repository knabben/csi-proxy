CMDS=csi-proxy
all: build test

# include release tools for building binary and testing targets
include release-tools/build.make

BUILD_PLATFORMS=windows amd64 .exe
GOPATH ?= $(shell go env GOPATH)
REPO_ROOT = $(CURDIR)
BUILD_DIR = build
BUILD_TOOLS_DIR = $(BUILD_DIR)/tools
GO_ENV_VARS = GO111MODULE=on GOOS=windows
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
		local FILE_DIR="$$(dirname "$(GOPATH)/$$FILE")"; \
                echo "Generating protobuf file from $$FILE in $$FILE_DIR"; \
                protoc -I "$(GOPATH)/src/" -I '$(REPO_ROOT)/client/api' "$$FILE" --go_out=plugins="grpc:$(GOPATH)/src"; \
        } ; \
        export -f generate_protobuf_for; \
        find '$(REPO_ROOT)' -not -path './vendor/*' -name '*.proto' | sed -e "s|$(GOPATH)/src/||g" | xargs -n1 '$(SHELL)' -c 'generate_protobuf_for "$$0"'

.PHONY: generate-csi-proxy-api-gen
generate-csi-proxy-api-gen: compile-csi-proxy-api-gen
	$(CSI_PROXY_API_GEN) -i github.com/kubernetes-csi/csi-proxy/client/api,github.com/kubernetes-csi/csi-proxy/integrationtests/apigroups/api/dummy --v=8

.PHONY: clean
clean: clean-protobuf clean-generated

.PHONY: clean-protobuf
clean-protobuf:
	find '$(REPO_ROOT)' -name '*.proto' -exec '$(SHELL)' -c 'rm -vf "$$(dirname {})/$$(basename {} .proto).pb.go"' \;

.PHONY: clean-generated
clean-generated:
	find '$(REPO_ROOT)' -name '*_generated.go' -exec '$(SHELL)' -c '[[ "$$(head -n 1 "{}")" == "// Code generated by csi-proxy-api-gen"* ]] && rm -v {}' \;

# see https://github.com/golangci/golangci-lint/releases
GOLANGCI_LINT_VERSION = v1.21.0
GOLANGCI_LINT = $(BUILD_TOOLS_DIR)/golangci-lint/$(GOLANGCI_LINT_VERSION)/golangci-lint

.PHONY: lint
lint: $(GOLANGCI_LINT)
	$(GO_ENV_VARS) $(GOLANGCI_LINT) run
	git --no-pager diff --exit-code

.PHONY: test-go
test: test-go
test-go:
	@ echo; echo "### $@:"
	# TODO: After issue https://github.com/microsoft/go-winio/pull/169 is resolved, remove the filter on the test path.
	GO111MODULE=on go test `find ./internal/server/ -type d -not -name server`;\
        cd client && GO111MODULE=on go test `go list ./... | grep -v group` && cd ../

.PHONY: test-vet
test: test-vet
test-vet:
	@ echo; echo "### $@:"
	# TODO: After issue https://github.com/microsoft/go-winio/pull/169 is resolved, remove the filter on the test path.
	# GO111MODULE=on go vet `find ./internal/server/ -type d -not -name server`;\
        cd client && GO111MODULE=on go vet `go list ./... | grep -v group` && cd ../
# see https://github.com/golangci/golangci-lint#binary-release
$(GOLANGCI_LINT):
curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$$(dirname '$(GOLANGCI_LINT)')" '$(GOLANGCI_LINT_VERSION)'
