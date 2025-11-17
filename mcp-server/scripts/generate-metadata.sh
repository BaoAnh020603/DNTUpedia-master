#!/bin/bash

# Generates metadata files for Amazon Bedrock Knowledge Base documents.
# Creates .metadata.json files with role-based access control:
# - docs/external/ → role=1 (public)
# - docs/internal/ → role=4 (private)
# Refer: https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-knowledge-bases-now-supports-metadata-filtering-to-improve-retrieval-accuracy/#:~:text=Prepare%20a%20dataset%20for%20Amazon%20Bedrock%20Knowledge%20Bases

EXTERNAL_DIR=external
INTERNAL_DIR=internal

set -e  # Exit on any error

# Load environment variables
source ../.env

# Validate required environment variable
if [[ -z "${DOC_DIRECTORY:-}" ]]; then
    echo "Error: DOC_DIRECTORY environment variable is not set"
    exit 1
fi

doc_dir=${DOC_DIRECTORY}

# Check if directory exists
if [[ ! -d "$doc_dir" ]]; then
    echo "Error: Directory $doc_dir does not exist"
    exit 1
fi

cd "$doc_dir"

# Process both external/ and internal/ directories
for dir in $EXTERNAL_DIR $INTERNAL_DIR; do
    if [[ ! -d "$dir" ]]; then
        echo "Warning: Directory $dir does not exist, skipping..."
        continue
    fi
    
    # Set role based on directory
    case "$dir" in
        "$EXTERNAL_DIR") role=1 ;;
        "$INTERNAL_DIR") role=4 ;;
        *) echo "Warning: Unknown directory $dir"; continue ;;
    esac
    
    # Counter for processed files
    count=0
    
    for file in "$dir"/*; do
        # Skip if not a file
        [[ -f "$file" ]] || continue
        
        # Skip metadata files themselves
        [[ "$file" == *.metadata.json ]] && continue
        
        filename=$(basename "$file")
        metadata_file="${dir}/${filename}.metadata.json"
        
        # Provide clear feedback
        if [[ -f "$metadata_file" ]]; then
            echo "  ↻ Replacing: ${filename}.metadata.json (role=$role)"
        else
            echo "  ✓ Creating: ${filename}.metadata.json (role=$role)"
        fi
        
        # Generate metadata file
        cat > "$metadata_file" <<EOF
{
    "metadataAttributes": {
        "role": $role
    }
}
EOF
        ((count++))
    done
    
done

echo "Metadata generation complete!"