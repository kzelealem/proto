#!/bin/bash

# Dart Protobuf Compilation Script with Automated Export File Generation
# Usage: ./dart-build.sh <proto-source-directory> <dart-flutter-package-directory>
# Example: ./dart-build.sh . ../proto-gen/dart/proto_gen

# Check for required arguments
#!/bin/bash
#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <proto-source-directory> <dart-flutter-package-directory>"
    exit 1
fi

PROTO_SRC_DIR=$1  # Directory containing proto files
DART_PKG_DIR=$2   # Directory of the Flutter package

# Define proto subdirectories
PUBLIC_PROTO_DIR="${PROTO_SRC_DIR}/public"
GOOGLE_API_DIR="${PROTO_SRC_DIR}/google/api"

# Ensure the output directory exists
DART_OUT_DIR="${DART_PKG_DIR}/lib/generated"
mkdir -p "${DART_OUT_DIR}"

# Export file
EXPORT_FILE="${DART_PKG_DIR}/lib/proto_gen.dart"
echo "// Auto-generated file" > "${EXPORT_FILE}"

# Function to compile proto files and append exports
compile_protos() {
    local proto_dir=$1
    # Compute the relative path from PROTO_SRC_DIR to proto_dir
    local relative_path=${proto_dir#${PROTO_SRC_DIR}/}

    for file in "${proto_dir}"/*.proto; do
        local filename=$(basename -- "${file}")
        local basename="${filename%.*}"

        # Generate -I flags based on imports
        local import_flags=""
        while IFS= read -r line; do
            if [[ $line == import*google/* ]]; then
                import_path=$(echo "$line" | sed 's|import "\(google/.*\)";|\1|')
                import_flags+=" ${import_path}"
            fi
        done < "${file}"

        # Ensure the output directory exists
        mkdir -p "${DART_OUT_DIR}"

        # Compile proto file with the necessary -I flags
        protoc --experimental_allow_proto3_optional --dart_out=grpc:"${DART_OUT_DIR}" -I"${PROTO_SRC_DIR}"${import_flags} "${file}"

        # Use the relative path in the export line
        echo "export 'generated/${relative_path}/${basename}.pb.dart';" >> "${EXPORT_FILE}"
    done
}

# Compile proto files from 'public' directory
echo "Compiling public proto files for Dart..."
compile_protos "${PUBLIC_PROTO_DIR}"

# Compile proto files from 'google/api' directory
echo "Compiling google/api proto files for Dart..."
compile_protos "${GOOGLE_API_DIR}"

echo "Dart compilation completed."
