#!/bin/bash
# Usage: ./generate_project.sh <project-name> <group-name> <comma-separated-packages> [comma-separated-apis] [java-version]
set -euo pipefail

# Validate arguments
if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <project-name> <group-name> <comma-separated-packages> [comma-separated-apis]"
  exit 1
fi

PROJECT_NAME=$1
GROUP_NAME=$2
PACKAGES_CSV=${3:-}
APIS=${4:-}  # optional; e.g., "GET,POST,PUT,DELETE"
JAVA_VERSION=${5:-17} # default to 17 if not provided

# Export variables so that sub-scripts can use them.
export PROJECT_NAME GROUP_NAME PACKAGES_CSV APIS JAVA_VERSION

# Convert project name to package name (remove hyphens and lower-case)
export PACKAGE_NAME
PACKAGE_NAME=$(tr -d '-' <<< "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

# Function to convert a hyphenated string to CamelCase
camelize() {
  IFS='-' read -ra tokens <<< "$1"
  local result=""
  for token in "${tokens[@]}"; do
    result+=$(tr '[:lower:]' '[:upper:]' <<< "${token:0:1}")"${token:1}"
  done
  echo "$result"
}

export CAMEL_PROJECT_NAME=$(camelize "$PROJECT_NAME")
export APP_CLASS_NAME="${CAMEL_PROJECT_NAME}Application"

# Convert group name to directory structure (e.g., in.oceanbytes -> in/oceanbytes)
export BASE_PACKAGE_DIR
BASE_PACKAGE_DIR=$(tr '.' '/' <<< "$GROUP_NAME")
export BASE_DIR="$PROJECT_NAME/src/main/java/${BASE_PACKAGE_DIR}/${PACKAGE_NAME}"

# Run sub-scripts
./create_directories.sh
./generate_configs.sh
./generate_classes.sh

echo "Project '$PROJECT_NAME' generated successfully!"