#!/bin/bash
# Usage: ./generate_project.sh <project-name> <group-name> <comma-separated-packages>
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <project-name> <group-name> <comma-separated-packages>"
  exit 1
fi

PROJECT_NAME=$1
GROUP_NAME=$2
PACKAGES_CSV=$3

# For package directories, remove hyphens and convert to lowercase.
PACKAGE_NAME=$(echo "$PROJECT_NAME" | tr -d '-' | tr '[:upper:]' '[:lower:]')

# Convert project name to CamelCase for the main class.
IFS='-' read -ra TOKENS <<< "$PROJECT_NAME"
CAMEL_PROJECT_NAME=""
for token in "${TOKENS[@]}"; do
    # Capitalize the first letter and append the rest unchanged.
    first_letter=$(echo "${token:0:1}" | tr '[:lower:]' '[:upper:]')
    rest=${token:1}
    CAMEL_PROJECT_NAME="${CAMEL_PROJECT_NAME}${first_letter}${rest}"
done
APP_CLASS_NAME="${CAMEL_PROJECT_NAME}Application"

# Convert group name to directory structure (e.g., in.oceanbytes -> in/oceanbytes)
BASE_PACKAGE_DIR=$(echo "$GROUP_NAME" | tr '.' '/')

# Define the base package path for the generated project
BASE_DIR="$PROJECT_NAME/src/main/java/${BASE_PACKAGE_DIR}/${PACKAGE_NAME}"
mkdir -p "$BASE_DIR"

# Create additional package directories based on the comma-separated list
IFS=',' read -ra PKGS <<< "$PACKAGES_CSV"
for pkg in "${PKGS[@]}"; do
  pkg=$(echo $pkg | xargs)  # trim whitespace
  if [ ! -z "$pkg" ]; then
    mkdir -p "$BASE_DIR/$pkg"
  fi
done

# Create directories for resources and tests
mkdir -p "$PROJECT_NAME/src/main/resources"
mkdir -p "$PROJECT_NAME/src/test/java/${BASE_PACKAGE_DIR}/${PACKAGE_NAME}"

# Write the application.yml file into src/main/resources
cat <<EOF > "$PROJECT_NAME/src/main/resources/application.yml"
server:
  port: 8080
  servlet:
    context-path: /api/$PROJECT_NAME

logging:
  level:
    root: INFO
EOF

# Write the pom.xml file with dynamic groupId and artifactId (simplified example)
cat <<EOF > "$PROJECT_NAME/pom.xml"
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

# Create a basic Spring Boot main application class using the CamelCase name.
cat <<EOF > "$BASE_DIR/${APP_CLASS_NAME}.java"
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

echo "Project '$PROJECT_NAME' generated successfully with package ${GROUP_NAME}.${PACKAGE_NAME}, main class ${APP_CLASS_NAME}, and application.yml with context-path /api/$PROJECT_NAME!"
