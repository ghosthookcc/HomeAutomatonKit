PROTO_VERSION = 33.1

PROTO_DIR=proto
IGNORE_DIR := include # relative to PROTO_DIR

PROTO_URL_WIN = https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTO_VERSION)/protoc-$(PROTO_VERSION)-win64.zip
PROTO_URL_LINUX = https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTO_VERSION)/protoc-$(PROTO_VERSION)-linux-x86_64.zip
PROTO_URL_OSX = https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTO_VERSION)/protoc-$(PROTO_VERSION)-osx-x86_64.zip

OUT_DIR=proto-stubs/impl
MODULE ?= go

OUT_IMPL_DIR := $(OUT_DIR)/impl/$(MODULE)

ifeq ($(OS),Windows_NT)
PROTO_FILES := $(shell powershell -NoProfile -Command \
	"Get-ChildItem '$(PROTO_DIR)' -Recurse -Filter '*.proto' | " \
	"Where-Object { ($$_.FullName -replace '\\\\','/') -notmatch '\\include\\' } | " \
	"ForEach-Object { ($$_.FullName -replace '\\\\','/').Substring($$PWD.Path.Length + 1) }")
NANOPB_PLUGIN := $(shell python -c "import nanopb.generator; import os; print(os.path.join(os.path.dirname(nanopb.generator.__file__), 'protoc-gen-nanopb.bat'))")
else
PROTO_FILES := $(shell find $(PROTO_DIR) -name '*.proto' ! -path '$(PROTO_DIR)/include/*' -printf '%P\n')
NANOPB_PLUGIN := $(shell python -c "import nanopb.generator; import os; print(os.path.join(os.path.dirname(nanopb.generator.__file__), 'protoc-gen-nanopb'))")
endif

PROTOC=protoc

all: install setup proto

install:
ifeq ($(MODULE),go)
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
endif
ifeq ($(MODULE),python)
	pip install grpcio-tools
	pip install nanopb
endif
ifeq ($(OS),Windows_NT)
	@echo "==> Downloading protoc $(PROTO_VERSION) for Windows..."
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
	powershell -Command "Invoke-WebRequest -Uri '$(PROTO_URL_WIN)' -OutFile '$(PROTO_DIR)/protoc.zip'"
	powershell -Command "Expand-Archive -Path '$(PROTO_DIR)/protoc.zip' -DestinationPath '$(PROTO_DIR)' -Force"
	powershell -Command "if (Test-Path '$(PROTO_DIR)/bin') { Remove-Item -Path $(PROTO_DIR)/bin -Recurse -Force }"
	powershell -Command "Remove-Item -Path '$(PROTO_DIR)/protoc.zip'"
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		URL := $(PROTO_URL_OSX)
	else
		URL := $(PROTO_URL_LINUX)
	endif
	@echo "==> Downloading protoc $(PROTO_VERSION) for $(UNAME_S)..."
	mkdir -p $(PROTO_DIR)
	curl -L $(URL) -o $(PROTO_DIR)/protoc.zip
	unzip -o $(PROTO_DIR)/protoc.zip -d $(PROTO_DIR)
	rm -dr $(PROTO_DIR)/bin
	rm $(PROTO_DIR)/protoc.zip
endif

setup:
	@echo "==> Setting up workspace . . ."
ifeq ($(OS),Windows_NT)
	powershell -Command "New-Item -ItemType Directory -Path '$(OUT_DIR)' -Force"
else
	mkdir -p $(OUT_DIR)
endif

proto:
	@echo "==> Generating '$(MODULE)' gRPC code . . ."
ifeq ($(OS),Windows_NT)
	powershell -Command "New-Item -ItemType Directory -Path '$(OUT_IMPL_DIR)' -Force"
else
	mkdir -p $(OUT_IMPL_DIR)
endif
ifeq ($(MODULE),go)
	protoc -I$(PROTO_DIR) \
		   -I$(PROTO_DIR)/include \
	       --go_out=$(OUT_IMPL_DIR) --go_opt=paths=source_relative \
	       --go-grpc_out=$(OUT_IMPL_DIR) --go-grpc_opt=paths=source_relative \
	       $(PROTO_FILES)
endif
ifeq ($(MODULE),python)
	protoc -I$(PROTO_DIR) \
		   -I$(PROTO_DIR)/include \
	       --python_out=$(OUT_IMPL_DIR) \
	       $(PROTO_FILES)
endif
ifeq ($(MODULE),java)
	protoc -I$(PROTO_DIR) \
		   -I$(PROTO_DIR)/include \
	       --java_out=$(OUT_IMPL_DIR) \
	       $(PROTO_FILES)
endif
ifeq ($(MODULE),esp32)
	@$(foreach file,$(PROTO_FILES), \
		echo Generating $(file) && \
		protoc -I$(PROTO_DIR) -I$(PROTO_DIR)/include --plugin=protoc-gen-nanopb=$(NANOPB_PLUGIN) --nanopb_out=$(OUT_IMPL_DIR) "$(file)" && \
	) echo Done
endif

.PHONY: all install setup proto
