#!/bin/bash
# Usage: ./generate_project.sh <project-name> <group-name> <comma-separated-packages> [comma-separated-apis]

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <project-name> <group-name> <comma-separated-packages> [comma-separated-apis]"
  exit 1
fi

PROJECT_NAME=$1
GROUP_NAME=$2
PACKAGES_CSV=$3
APIS=${4:-}  # optional; e.g., "GET,POST,PUT,DELETE"

# Convert project name to package name: remove hyphens and lower-case
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

CAMEL_PROJECT_NAME=$(camelize "$PROJECT_NAME")
APP_CLASS_NAME="${CAMEL_PROJECT_NAME}Application"

# Convert group name to directory structure (e.g., in.oceanbytes -> in/oceanbytes)
BASE_PACKAGE_DIR=$(tr '.' '/' <<< "$GROUP_NAME")
BASE_DIR="$PROJECT_NAME/src/main/java/${BASE_PACKAGE_DIR}/${PACKAGE_NAME}"

# Create necessary directories in one go
mkdir -p "$BASE_DIR" \
         "$PROJECT_NAME/src/main/resources" \
         "$PROJECT_NAME/src/test/java/${BASE_PACKAGE_DIR}/${PACKAGE_NAME}"

# Create additional package directories based on the comma-separated list (trimming whitespace)
IFS=',' read -ra PKGS <<< "$PACKAGES_CSV"
for pkg in "${PKGS[@]}"; do
  pkg=$(echo "$pkg" | xargs)
  [[ -n "$pkg" ]] && mkdir -p "$BASE_DIR/$pkg"
done

# Write application.yml
cat > "$PROJECT_NAME/src/main/resources/application.yml" <<EOF
server:
  port: 8080
  servlet:
    context-path: /api/$PROJECT_NAME

logging:
  level:
    root: INFO
EOF

# Write pom.xml with dynamic groupId and artifactId
cat > "$PROJECT_NAME/pom.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.4.4</version>
        <relativePath/>
    </parent>
    <groupId>$GROUP_NAME</groupId>
    <artifactId>$PROJECT_NAME</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>$PROJECT_NAME</name>
    <description>Demo project for Spring Boot</description>
    <properties>
        <java.version>17</java.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# Create the main Spring Boot application class
cat > "$BASE_DIR/${APP_CLASS_NAME}.java" <<EOF
package ${GROUP_NAME}.${PACKAGE_NAME};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${APP_CLASS_NAME} {
    public static void main(String[] args) {
        SpringApplication.run(${APP_CLASS_NAME}.class, args);
    }
}
EOF

# If "controllers" is among the provided packages, generate ExampleController.java with API methods if provided.
if echo "$PACKAGES_CSV" | grep -iwq "controllers"; then
  API_METHODS=""
  APIS=$(echo "$APIS" | xargs)
  if [[ -n "$APIS" ]]; then
    IFS=',' read -ra API_ARRAY <<< "$APIS"
    for api in "${API_ARRAY[@]}"; do
      api_upper=$(tr '[:lower:]' '[:upper:]' <<< "$api")
      case "$api_upper" in
        GET)
          API_METHODS+=$'\n'"    @GetMapping
    public ResponseEntity<List<String>> getAllItems() {
        return ResponseEntity.ok(new ArrayList<>(items.values()));
    }

    @GetMapping(\"/{id}\")
    public ResponseEntity<String> getItemById(@PathVariable Long id) {
        String item = items.get(id);
        return item != null ? ResponseEntity.ok(item) : ResponseEntity.notFound().build();
    }"
          ;;
        POST)
          API_METHODS+=$'\n'"    @PostMapping
    public ResponseEntity<String> createItem(@RequestBody String item) {
        long id = idCounter++;
        items.put(id, item);
        return ResponseEntity.status(HttpStatus.CREATED).body(\"Item created with ID: \" + id);
    }"
          ;;
        PUT)
          API_METHODS+=$'\n'"    @PutMapping(\"/{id}\")
    public ResponseEntity<String> updateItem(@PathVariable Long id, @RequestBody String newItem) {
        if (!items.containsKey(id)) {
            return ResponseEntity.notFound().build();
        }
        items.put(id, newItem);
        return ResponseEntity.ok(\"Item updated successfully\");
    }"
          ;;
        DELETE)
          API_METHODS+=$'\n'"    @DeleteMapping(\"/{id}\")
    public ResponseEntity<String> deleteItem(@PathVariable Long id) {
        if (!items.containsKey(id)) {
            return ResponseEntity.notFound().build();
        }
        items.remove(id);
        return ResponseEntity.ok(\"Item deleted successfully\");
    }"
          ;;
        *)
          # Skip unknown API types.
          ;;
      esac
    done
  fi

  cat > "$BASE_DIR/controllers/ExampleController.java" <<EOF
package ${GROUP_NAME}.${PACKAGE_NAME}.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/v1")
public class ExampleController {

    private Map<Long, String> items = new ConcurrentHashMap<>();
    private long idCounter = 1;

${API_METHODS}
}
EOF
fi

# Generate .gitignore
cat > "$PROJECT_NAME/.gitignore" <<'EOL'
HELP.md
target/
!.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

### IntelliJ IDEA ###
.idea
*.iws
*.iml
*.ipr

### NetBeans ###
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/
build/
!**/src/main/**/build/
!**/src/test/**/build/

### VS Code ###
.vscode/
EOL

echo "Project '$PROJECT_NAME' generated successfully with package ${GROUP_NAME}.${PACKAGE_NAME}, main class ${APP_CLASS_NAME}, application.yml, and controller (if selected)!"
