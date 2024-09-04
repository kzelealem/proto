#!/bin/bash

# run with this command:
#   ./go-build.sh . ../proto-gen/go

# $1 is the base directory where proto files are located (e.g., "./proto")
# $2 is the base output directory for the generated Go files (e.g., "./proto-gen/go")

for package in private public; do
  protoc --experimental_allow_proto3_optional \
      --proto_path="$1" \
      --go_opt=paths=source_relative \
      --go_out="$2" \
      --go-grpc_out="$2" \
      --go-grpc_opt=paths=source_relative \
      --grpc-gateway_out="$2" \
      --grpc-gateway_opt=paths=source_relative \
      "$1"/${package}/*.proto && \
      ls "$2"/${package}/*.pb.go
done
