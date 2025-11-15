PROTO_DIR=proto
OUT_DIR=./

PROTO_FILES=$(PROTO_DIR)/*.proto

PROTOC=protoc

all: proto

proto:
	@echo "==> Generating Go gRPC code from proto files..."
	$(PROTOC) \
		--go_out=$(OUT_DIR) --go_opt=paths=source_relative \
		--go-grpc_out=$(OUT_DIR) --go-grpc_opt=paths=source_relative \
		$(PROTO_FILES)
	@echo "==> Done."

install-tools:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

.PHONY: all proto install-tools
