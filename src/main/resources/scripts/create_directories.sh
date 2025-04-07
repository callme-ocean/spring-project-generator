#!/bin/bash
set -euo pipefail

# Create main directories
mkdir -p "$BASE_DIR" \
         "$PROJECT_NAME/src/main/resources" \
         "$PROJECT_NAME/src/test/java/${BASE_PACKAGE_DIR}/${PACKAGE_NAME}"

# Create additional package directories from comma-separated list
IFS=',' read -ra PKGS <<< "$PACKAGES_CSV"
for pkg in "${PKGS[@]}"; do
  pkg=$(echo "$pkg" | xargs)  # Trim whitespace
  [[ -n "$pkg" ]] && mkdir -p "$BASE_DIR/$pkg"
done
