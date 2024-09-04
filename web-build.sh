#!/bin/bash

# run with this command:
#   ./web-build.sh . ../proto-gen/web

# Check for required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <proto-source-directory> <js-output-directory>"
    exit 1
fi

PROTO_SRC_DIR=$1  # Directory containing proto files
JS_OUT_DIR=$2     # Directory to place generated JS files

# Define proto subdirectories
PUBLIC_PROTO_DIR="${PROTO_SRC_DIR}/public"

# Ensure output directory exists
mkdir -p ${JS_OUT_DIR}

# Function to compile proto files
compile_protos() {
    local proto_dir=$1
    for file in "${proto_dir}"/*.proto; do
        grpc_tools_node_protoc -I="${PROTO_SRC_DIR}" \
               --js_out=import_style=commonjs:${JS_OUT_DIR} \
               --grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR} \
               "${file}"
    done
}

# Compile proto files
echo "Compiling public proto files..."
compile_protos ${PUBLIC_PROTO_DIR}

echo "Compilation completed."
