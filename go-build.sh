#!/bin/bash

# Run with this command:
#   ./swagger-build.sh . ../proto-gen/swagger

# Check for required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <proto-source-directory> <swagger-output-directory>"
    exit 1
fi

PROTO_SRC_DIR=$1  # Directory containing proto files
SWAGGER_OUT_DIR=$2  # Directory to place generated Swagger files

# Ensure output directories exist
mkdir -p ${SWAGGER_OUT_DIR}

# Function to compile Swagger files from proto files
compile_swagger() {
    local package=$1
    local proto_dir="${PROTO_SRC_DIR}/${package}"

    # Check if proto directory exists and has files
    if [ ! -d "${proto_dir}" ]; then
        echo "Directory ${proto_dir} does not exist!"
        return
    fi

    proto_files=$(ls "${proto_dir}"/*.proto 2>/dev/null)

    if [ -z "$proto_files" ]; then
        echo "No .proto files found in ${proto_dir}."
        return
    fi

    for file in "${proto_dir}"/*.proto; do
        protoc --experimental_allow_proto3_optional \
            --proto_path=${PROTO_SRC_DIR} \
            --openapiv2_out=${SWAGGER_OUT_DIR} \
            --openapiv2_opt=use_go_templates=true \
            "${file}"
        
        if [ $? -eq 0 ]; then
            echo "Successfully generated Swagger for ${file}."
        else
            echo "Failed to generate Swagger for ${file}."
        fi
    done
}

# Compile Swagger files for private and public packages
echo "Compiling Swagger files for private proto files..."
compile_swagger private

echo "Compiling Swagger files for public proto files..."
compile_swagger public

echo "Swagger generation completed."
