#!/bin/bash
# Usage: ./generate_project.sh <project-name> <comma-separated-packages>
if [ -z "$1" ]; then
  echo "Usage: $0 <project-name> <comma-separated-packages>"
  exit 1
fi

PROJECT_NAME=$1
PACKAGES_CSV=$2

echo "Creating project '$PROJECT_NAME' with packages: $PACKAGES_CSV..."

# Create base package directory
BASE_DIR="$PROJECT_NAME/src/main/java/com/example/demo"
mkdir -p "$BASE_DIR"

# Create package directories from comma-separated list
IFS=',' read -ra PKGS <<< "$PACKAGES_CSV"
for pkg in "${PKGS[@]}"; do
  pkg=$(echo $pkg | xargs)  # trim any whitespace
  if [ ! -z "$pkg" ]; then
    mkdir -p "$BASE_DIR/$pkg"
  fi
done

# Also create standard directories for resources and tests
mkdir -p "$PROJECT_NAME/src/main/resources"
mkdir -p "$PROJECT_NAME/src/test/java/com/example/demo"

# Write the pom.xml file
cat <<'EOF' > "$PROJECT_NAME/pom.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>3.4.4</version>
		<relativePath/> <!-- lookup parent from repository -->
	</parent>
	<groupId>com.example</groupId>
	<artifactId>demo</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name>demo</name>
	<description>Demo project for Spring Boot</description>
	<url/>
	<licenses>
		<license/>
	</licenses>
	<developers>
		<developer/>
	</developers>
	<scm>
		<connection/>
		<developerConnection/>
		<tag/>
		<url/>
	</scm>
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

# Create a basic Spring Boot main application class
cat <<'EOF' > "$BASE_DIR/DemoApplication.java"
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
  public static void main(String[] args) {
    SpringApplication.run(DemoApplication.class, args);
  }
}
EOF

echo "Project '$PROJECT_NAME' generated successfully!"
