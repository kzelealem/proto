#!/bin/bash

# run with this command:
#   ./swagger-build.sh . ../proto-gen/swagger

# $1 is the base directory where proto files are located (e.g., "./proto")
# $2 is the base output directory for the generated Go files (e.g., "./proto-gen/swagger")

mkdir -p $2

for package in private public; do
  protoc --experimental_allow_proto3_optional \
      --proto_path="$1" \
      --openapiv2_out "$2" --openapiv2_opt use_go_templates=true \
        "$1"/${package}/*.proto && \
        ls "$2"/${package}/*.swagger.json

done
