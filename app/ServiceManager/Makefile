PROTO_VERSION = 33.1

PROTO_DIR=proto

PROTO_URL_WIN = https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTO_VERSION)/protoc-$(PROTO_VERSION)-win64.zip
PROTO_URL_LINUX = https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTO_VERSION)/protoc-$(PROTO_VERSION)-linux-x86_64.zip
PROTO_URL_OSX = https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTO_VERSION)/protoc-$(PROTO_VERSION)-osx-x86_64.zip

OUT_DIR=proto-stubs

PROTO_FILES=$(PROTO_DIR)/*.proto

PROTOC=protoc

all: install proto

proto:
	@echo "==> Generating Go gRPC code..."
ifeq ($(OS),Windows_NT)
	if not exist $(OUT_DIR) mkdir $(OUT_DIR)
else
	mkdir -p $(OUT_DIR)
endif
	$(PROTOC) \
		-I$(PROTO_DIR) \
		-I$(PROTO_DIR)/include \
		--go_out=$(OUT_DIR) --go_opt=paths=source_relative \
		--go-grpc_out=$(OUT_DIR) --go-grpc_opt=paths=source_relative \
		$(PROTO_DIR)/*.proto

install:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
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


.PHONY: all install proto
