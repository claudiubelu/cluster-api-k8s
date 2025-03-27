# Copyright 2020 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# If you update this file, please follow
# https://www.thapaliya.com/en/writings/well-documented-makefiles/

# Ensure Make is run with bash shell as some syntax below is bash-specific
SHELL:=/usr/bin/env bash

.DEFAULT_GOAL:=help

GO_VERSION ?= 1.22.6
GO_CONTAINER_IMAGE ?= docker.io/library/golang:$(GO_VERSION)

ARCH ?= $(shell go env GOARCH)

# Use GOPROXY environment variable if set
GOPROXY := $(shell go env GOPROXY)
ifeq ($(GOPROXY),)
GOPROXY := https://proxy.golang.org
endif
export GOPROXY

# Active module mode, as we use go modules to manage dependencies
export GO111MODULE=on

GO_INSTALL := ./hack/go_install.sh

BIN_DIR := bin
TOOLS_BIN_DIR := $(shell pwd)/$(BIN_DIR)
$(TOOLS_BIN_DIR):
	mkdir -p $(TOOLS_BIN_DIR)


# Produce CRDs that work back to Kubernetes 1.11 (no version conversion)
CRD_OPTIONS ?= "crd:trivialVersions=true"

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# Sync to controller-tools version in https://github.com/kubernetes-sigs/cluster-api/blob/v{VERSION}/hack/tools/go.mod
CONTROLLER_GEN_VER := v0.16.1
CONTROLLER_GEN_BIN := controller-gen
CONTROLLER_GEN := $(TOOLS_BIN_DIR)/$(CONTROLLER_GEN_BIN)-$(CONTROLLER_GEN_VER)

# Sync
CONVERSION_GEN_VER := v0.29.0
CONVERSION_GEN_BIN := conversion-gen
CONVERSION_GEN := $(TOOLS_BIN_DIR)/$(CONVERSION_GEN_BIN)-$(CONVERSION_GEN_VER)

# Sync to github.com/drone/envsubst/v2 in https://github.com/kubernetes-sigs/cluster-api/blob/v{VERSION}/go.mod
ENVSUBST_VER := v2.0.0-20210730161058-179042472c46
ENVSUBST_BIN := envsubst
ENVSUBST := $(TOOLS_BIN_DIR)/$(ENVSUBST_BIN)

ENVTEST_VER := release-0.20
ENVTEST_BIN := setup-envtest
ENVTEST := $(TOOLS_BIN_DIR)/$(ENVTEST_BIN)
ENVTEST_K8S_VERSION = "1.32.0"

# Sync to github.com/drone/envsubst/v2 in https://github.com/kubernetes-sigs/cluster-api/blob/v{VERSION}/go.mod
ENVSUBST_VER := v2.0.0-20210730161058-179042472c46
ENVSUBST_BIN := envsubst
ENVSUBST := $(TOOLS_BIN_DIR)/$(ENVSUBST_BIN)

# Bump as necessary/desired to latest that supports our version of go at https://github.com/golangci/golangci-lint/releases
GOLANGCI_LINT_VER := v1.61.0
GOLANGCI_LINT_BIN := golangci-lint
GOLANGCI_LINT := $(TOOLS_BIN_DIR)/$(GOLANGCI_LINT_BIN)-$(GOLANGCI_LINT_VER)

# Keep at 4.0.4 until we figure out how to get later verisons to not mangle the calico yamls
# HACK bump latest version once https://github.com/kubernetes-sigs/kustomize/issues/947 is fixed
KUSTOMIZE_VER := v4.5.2
KUSTOMIZE_BIN := kustomize
KUSTOMIZE := $(TOOLS_BIN_DIR)/$(KUSTOMIZE_BIN)-$(KUSTOMIZE_VER)

# Ginkgo
TEST_DIR := $(shell pwd)/test
ARTIFACTS ?= $(shell pwd)/_artifacts
GINKGO_FOCUS ?=
GINKGO_SKIP ?=
GINKGO_NODES ?= 1 # GINKGO_NODES is the number of parallel nodes to run
                  # when running the e2e tests, 1 means no parallelism
GINKGO_TIMEOUT ?= 2h
GINKGO_POLL_PROGRESS_AFTER ?= 60m
GINKGO_POLL_PROGRESS_INTERVAL ?= 5m
E2E_INFRA ?= docker
E2E_CONF_FILE ?= $(TEST_DIR)/e2e/config/ck8s-$(E2E_INFRA).yaml
SKIP_RESOURCE_CLEANUP ?= false
USE_EXISTING_CLUSTER ?= false
GINKGO_NOCOLOR ?= false

# to set multiple ginkgo skip flags, if any
ifneq ($(strip $(GINKGO_SKIP)),)
_SKIP_ARGS := $(foreach arg,$(strip $(GINKGO_SKIP)),-skip="$(arg)")
endif

# Helper function to get dependency version from go.mod
get_go_version = $(shell go list -m $1 | awk '{print $$2}')

GINKGO_BIN := ginkgo
GINKGO_VER := $(call get_go_version,github.com/onsi/ginkgo/v2)
GINKGO := $(abspath $(TOOLS_BIN_DIR)/$(GINKGO_BIN)-$(GINKGO_VER))
GINKGO_PKG := github.com/onsi/ginkgo/v2/ginkgo


## --------------------------------------
## Development
## --------------------------------------

.PHONY: install
install: install-bootstrap install-controlplane

.PHONY: generate
generate: generate-bootstrap generate-controlplane

.PHONY: manifests
manifests: manifests-bootstrap manifests-controlplane

.PHONY: prepare
prepare: manifests generate

.PHONY: dev-bootstrap dev-controlplane
dev-bootstrap:
	ENABLE_WEBHOOKS=false go run ./bootstrap/main.go -metrics-addr=0

dev-controlplane:
	ENABLE_WEBHOOKS=false go run ./controlplane/main.go -metrics-addr=0

## --------------------------------------
## Release
## --------------------------------------

##@ release:

## latest git tag for the commit, e.g., v0.3.10
## set to v0.0.0 if no tag is found
RELEASE_TAG ?= $(shell git describe --abbrev=0 --tags 2>/dev/null || echo v0.0.0)
ifneq (,$(findstring -,$(RELEASE_TAG)))
    PRE_RELEASE=true
endif
# the previous release tag, e.g., v0.3.9, excluding pre-release tags
PREVIOUS_TAG ?= $(shell git tag -l | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$$" | sort -V | grep -B1 $(RELEASE_TAG) | head -n 1 2>/dev/null)
## set by Prow, ref name of the base branch, e.g., main
RELEASE_ALIAS_TAG := $(PULL_BASE_REF)
RELEASE_DIR := out
RELEASE_NOTES_DIR := _releasenotes

.PHONY: $(RELEASE_DIR)
$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)/

.PHONY: $(RELEASE_NOTES_DIR)
$(RELEASE_NOTES_DIR):
	mkdir -p $(RELEASE_NOTES_DIR)/

REGISTRY ?= ghcr.io/canonical/cluster-api-k8s

# Image URL to use all building/pushing image targets
BOOTSTRAP_IMG_TAG ?= $(RELEASE_TAG)
BOOTSTRAP_IMG ?= $(REGISTRY)/bootstrap-controller

# Image URL to use all building/pushing image targets
CONTROLPLANE_IMG_TAG ?= $(RELEASE_TAG)
CONTROLPLANE_IMG ?= $(REGISTRY)/controlplane-controller

go-vet:
	go vet ./...

go-fmt:
	go fmt ./...

test-unit: clear-cover_all test-common test-bootstrap test-controlplane

clear-cover_all:
	rm -f cover_all.out

test-common:
	go test $(shell pwd)/pkg/... -coverprofile cover.out
	cat cover.out >> cover_all.out

all-bootstrap: manager-bootstrap

# Run tests
test-bootstrap: envtest generate-bootstrap generate-bootstrap-conversions manifests-bootstrap
	KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) --bin-dir $(TOOLS_BIN_DIR) -p path)" go test $(shell pwd)/bootstrap/... -coverprofile cover.out
	cat cover.out >>  cover_all.out

# Build manager binary
manager-bootstrap: generate-bootstrap
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o bin/manager bootstrap/main.go

# Run against the configured Kubernetes cluster in ~/.kube/config
run-bootstrap: generate-bootstrap manifests-bootstrap
	go run ./bootstrap/main.go

# Install CRDs into a cluster
install-bootstrap: manifests-bootstrap
	$(KUSTOMIZE) build bootstrap/config/crd | kubectl apply -f -

# Uninstall CRDs from a cluster
uninstall-bootstrap: manifests-bootstrap
	$(KUSTOMIZE) build bootstrap/config/crd | kubectl delete -f -

# Deploy controller in the configured Kubernetes cluster in ~/.kube/config
deploy-bootstrap: manifests-bootstrap
	cd bootstrap/config/manager && $(KUSTOMIZE) edit set image controller=${BOOTSTRAP_IMG}:${BOOTSTRAP_IMG_TAG}
	$(KUSTOMIZE) build bootstrap/config/default | kubectl apply -f -

# Generate manifests e.g. CRD, RBAC etc.
manifests-bootstrap: $(KUSTOMIZE) $(CONTROLLER_GEN)
	$(CONTROLLER_GEN) paths=./bootstrap/... rbac:roleName=manager-role crd webhook output:crd:artifacts:config=bootstrap/config/crd/bases output:rbac:dir=bootstrap/config/rbac output:webhook:dir=bootstrap/config/webhook

release-bootstrap:$(RELEASE_DIR) manifests-bootstrap ## Release bootstrap
	cd bootstrap/config/manager && $(KUSTOMIZE) edit set image controller=${BOOTSTRAP_IMG}:${BOOTSTRAP_IMG_TAG}
	$(KUSTOMIZE) build bootstrap/config/default > $(RELEASE_DIR)/bootstrap-components.yaml

# Generate code
generate-bootstrap: $(CONTROLLER_GEN)
	$(CONTROLLER_GEN) object:headerFile="hack/boilerplate.go.txt" paths="$(shell pwd)/bootstrap/..."

generate-bootstrap-conversions: $(CONVERSION_GEN)
	$(CONVERSION_GEN) \
		--input-dirs=./bootstrap/api/v1beta1 \
		--extra-peer-dirs=sigs.k8s.io/cluster-api/api/v1beta1 \
		--build-tag=ignore_autogenerated_conversions \
		--output-file-base=zz_generated.conversion \
		--output-base=./ \
		--go-header-file=./hack/boilerplate.go.txt

.PHONY: docker-build-bootstrap
docker-build-bootstrap-%:
	DOCKER_BUILDKIT=1 docker build --build-arg builder_image=$(GO_CONTAINER_IMAGE) --build-arg goproxy=$(GOPROXY) --build-arg ARCH=$* --build-arg package=./bootstrap/main.go --build-arg ldflags="$(LDFLAGS)" . -t ${BOOTSTRAP_IMG}:${BOOTSTRAP_IMG_TAG}-$*
docker-build-bootstrap: manager-bootstrap docker-build-bootstrap-amd64 docker-build-bootstrap-arm64

docker-build-bootstrap-e2e: manager-bootstrap
	DOCKER_BUILDKIT=1 docker build --build-arg builder_image=$(GO_CONTAINER_IMAGE) --build-arg goproxy=$(GOPROXY) --build-arg ARCH=$(ARCH) --build-arg package=./bootstrap/main.go --build-arg ldflags="$(LDFLAGS)" . -t ${BOOTSTRAP_IMG}:${BOOTSTRAP_IMG_TAG}

# Push the bootstrap multiarch image
.PHONY: docker-push-bootstrap
docker-push-bootstrap-%: docker-build-bootstrap-%
	docker push ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG)-$*
docker-push-bootstrap: docker-push-bootstrap-amd64 docker-push-bootstrap-arm64

.PHONY: docker-manifest-bootstrap
docker-manifest-bootstrap: docker-push-bootstrap
	docker manifest rm ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG) || true
	docker manifest create ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG) --amend ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG)-amd64 --amend ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG)-arm64
	docker manifest annotate ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG) ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG)-amd64 --arch=amd64
	docker manifest annotate ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG) ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG)-arm64 --arch=arm64
	docker manifest push ${BOOTSTRAP_IMG}:$(BOOTSTRAP_IMG_TAG)

all-controlplane: manager-controlplane

# Run tests
test-controlplane: envtest generate-controlplane generate-controlplane-conversions manifests-controlplane
	KUBEBUILDER_ASSETS="$(shell $(ENVTEST) use $(ENVTEST_K8S_VERSION) --bin-dir $(TOOLS_BIN_DIR) -p path)" go test $(shell pwd)/controlplane/... -coverprofile cover.out
	cat cover.out >>  cover_all.out

.PHONY: docker-build-e2e
docker-build-e2e: ## Run docker-build-* targets for all the images with settings to be used for the e2e tests
    # please ensure the generated image name matches image names used in the E2E_CONF_FILE
    # and it also match the image tags in bootstrap/config/default and controlplane/config/default
	$(MAKE) BOOTSTRAP_IMG_TAG=dev docker-build-bootstrap-e2e
	$(MAKE) CONTROLPLANE_IMG_TAG=dev docker-build-controlplane-e2e

.PHONY: test-e2e
test-e2e: $(GINKGO) $(KUSTOMIZE) ## Run the end-to-end tests
	CAPI_KUSTOMIZE_PATH="$(KUSTOMIZE)" $(GINKGO) -v --trace -poll-progress-after=$(GINKGO_POLL_PROGRESS_AFTER) \
		-poll-progress-interval=$(GINKGO_POLL_PROGRESS_INTERVAL) --tags=e2e --focus="$(GINKGO_FOCUS)" \
		$(_SKIP_ARGS) --nodes=$(GINKGO_NODES) --timeout=$(GINKGO_TIMEOUT) --no-color=$(GINKGO_NOCOLOR) \
		--output-dir="$(ARTIFACTS)" --junit-report="junit.e2e_suite.1.xml" $(GINKGO_ARGS) $(TEST_DIR)/e2e -- \
	    -e2e.artifacts-folder="$(ARTIFACTS)" \
	    -e2e.config="$(E2E_CONF_FILE)" \
	    -e2e.skip-resource-cleanup=$(SKIP_RESOURCE_CLEANUP) -e2e.use-existing-cluster=$(USE_EXISTING_CLUSTER)

# Build manager binary
manager-controlplane: generate-controlplane
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o bin/manager controlplane/main.go

# Run against the configured Kubernetes cluster in ~/.kube/config
run-controlplane: generate-controlplane manifests-controlplane
	go run ./controlplane/main.go

# Install CRDs into a cluster
install-controlplane: manifests-controlplane
	$(KUSTOMIZE) build controlplane/config/crd | kubectl apply -f -

# Uninstall CRDs from a cluster
uninstall-controlplane: manifests-controlplane
	$(KUSTOMIZE) build controlplane/config/crd | kubectl delete -f -

# Deploy controller in the configured Kubernetes cluster in ~/.kube/config
deploy-controlplane: manifests-controlplane
	cd controlplane/config/manager && $(KUSTOMIZE) edit set image controller=${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)
	$(KUSTOMIZE) build controlplane/config/default | kubectl apply -f -

# Generate manifests e.g. CRD, RBAC etc.
manifests-controlplane: $(KUSTOMIZE) $(CONTROLLER_GEN)
	$(CONTROLLER_GEN) paths=./controlplane/... rbac:roleName=manager-role webhook crd output:crd:artifacts:config=controlplane/config/crd/bases output:rbac:dir=controlplane/config/rbac output:webhook:dir=controlplane/config/webhook

release-controlplane: $(RELEASE_DIR) manifests-controlplane ## Release control-plane
	cd controlplane/config/manager && $(KUSTOMIZE) edit set image controller=${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)
	$(KUSTOMIZE) build controlplane/config/default > $(RELEASE_DIR)/control-plane-components.yaml

generate-controlplane: $(CONTROLLER_GEN)
	$(CONTROLLER_GEN) object:headerFile="hack/boilerplate.go.txt" paths="$(shell pwd)/controlplane/..."

generate-controlplane-conversions: $(CONVERSION_GEN)
	$(CONVERSION_GEN) \
		--input-dirs=./controlplane/api/v1beta1 \
		--extra-peer-dirs=sigs.k8s.io/cluster-api/api/v1beta1 \
		--extra-peer-dirs=github.com/canonical/cluster-api-k8s/bootstrap/api/v1beta1 \
		--build-tag=ignore_autogenerated_conversions \
		--output-file-base=zz_generated.conversion \
		--output-base=./ \
		--go-header-file=./hack/boilerplate.go.txt

.PHONY: docker-build-controlplane
docker-build-controlplane-%:
	DOCKER_BUILDKIT=1 docker build --build-arg builder_image=$(GO_CONTAINER_IMAGE) --build-arg goproxy=$(GOPROXY) --build-arg ARCH=$* --build-arg package=./controlplane/main.go --build-arg ldflags="$(LDFLAGS)" . -t ${CONTROLPLANE_IMG}:${CONTROLPLANE_IMG_TAG}-$*
docker-build-controlplane: manager-controlplane docker-build-controlplane-amd64 docker-build-controlplane-arm64

docker-build-controlplane-e2e: manager-controlplane
	DOCKER_BUILDKIT=1 docker build --build-arg builder_image=$(GO_CONTAINER_IMAGE) --build-arg goproxy=$(GOPROXY) --build-arg ARCH=${ARCH} --build-arg package=./controlplane/main.go --build-arg ldflags="$(LDFLAGS)" . -t ${CONTROLPLANE_IMG}:${CONTROLPLANE_IMG_TAG}

# Push the controlplane multiarch image
.PHONY: docker-push-controlplane
docker-push-controlplane-%: docker-build-controlplane-%
	docker push ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)-$*
docker-push-controlplane: docker-push-controlplane-amd64 docker-push-controlplane-arm64

.PHONY: docker-manifest-controlplane
docker-manifest-controlplane: docker-push-controlplane
	docker manifest rm ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG) || true
	docker manifest create ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG) --amend ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)-amd64 --amend ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)-arm64
	docker manifest annotate ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG) ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)-amd64 --arch=amd64
	docker manifest annotate ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG) ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)-arm64 --arch=arm64
	docker manifest push ${CONTROLPLANE_IMG}:$(CONTROLPLANE_IMG_TAG)

release: release-bootstrap release-controlplane
	cp metadata.yaml $(RELEASE_DIR)/metadata.yaml

.PHONY: release-notes
release-notes: $(RELEASE_NOTES_DIR) $(RELEASE_NOTES)
	if [ -n "${PRE_RELEASE}" ]; then \
	echo ":rotating_light: This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/kubernetes-sigs/cluster-api/issues/new)." > $(RELEASE_NOTES_DIR)/$(RELEASE_TAG).md; \
	else \
	go run ./hack/tools/release/notes.go --from=$(PREVIOUS_TAG) > $(RELEASE_NOTES_DIR)/$(RELEASE_TAG).md; \
	fi

## --------------------------------------
## Help
## --------------------------------------

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


## --------------------------------------
## Linting
## --------------------------------------

.PHONY: lint
lint: $(GOLANGCI_LINT) ## Lint codebase
	$(GOLANGCI_LINT) run -v -c .golangci.yml

fmt:
	go fmt ./...


## --------------------------------------
## Tooling Binaries
## --------------------------------------
.PHONY: envtest
envtest: $(ENVTEST) ## Download envtest-setup locally if necessary.
$(ENVTEST): $(TOOLS_BIN_DIR)
	test -s $(TOOLS_BIN_DIR)/setup-envtest || GOBIN=$(TOOLS_BIN_DIR) go install sigs.k8s.io/controller-runtime/tools/setup-envtest@latest

$(ENVSUBST): ## Build envsubst from tools folder.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/drone/envsubst/v2/cmd/envsubst $(ENVSUBST_BIN) $(ENVSUBST_VER)

$(GOLANGCI_LINT): ## Download the golangci-lint binary, `go get` or `go install` is not supported https://golangci-lint.run/welcome/install/#install-from-sources
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(TOOLS_BIN_DIR) $(GOLANGCI_LINT_VER)
	mv "$(TOOLS_BIN_DIR)/golangci-lint" $(GOLANGCI_LINT)

$(GINKGO): # Build ginkgo from tools folder.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) $(GINKGO_PKG) $(GINKGO_BIN) $(GINKGO_VER)

## HACK replace with $(GO_INSTALL) once https://github.com/kubernetes-sigs/kustomize/issues/947 is fixed
$(KUSTOMIZE): ## Put kustomize into tools folder.
	mkdir -p $(TOOLS_BIN_DIR)
	rm -f $(TOOLS_BIN_DIR)/$(KUSTOMIZE_BIN)*
	curl -fsSL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s -- $(KUSTOMIZE_VER:v%=%) $(TOOLS_BIN_DIR)
	mv "$(TOOLS_BIN_DIR)/$(KUSTOMIZE_BIN)" $(KUSTOMIZE)
	ln -sf $(KUSTOMIZE) "$(TOOLS_BIN_DIR)/$(KUSTOMIZE_BIN)"

$(CONTROLLER_GEN): ## Build controller-gen from tools folder.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) sigs.k8s.io/controller-tools/cmd/controller-gen $(CONTROLLER_GEN_BIN) $(CONTROLLER_GEN_VER)

$(CONVERSION_GEN): ## Build conversion-gen from tools folder.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) k8s.io/code-generator/cmd/conversion-gen $(CONVERSION_GEN_BIN) $(CONVERSION_GEN_VER)
