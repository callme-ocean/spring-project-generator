# Build stage: compile with Maven on JDK 17
FROM maven:3.8.3-openjdk-17 AS build
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage: run the fat JAR on JDK 17
FROM ibm-semeru-runtimes:open-17.0.12_7_openj9-0.46.1-jdk
COPY --from=build target/spring-project-generator-1.0.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
