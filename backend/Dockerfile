# ---- Stage 1: Build using Maven ----
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory inside builder stage
WORKDIR /build

# Copy pom.xml and download dependencies first (layer caching)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the full source code after dependencies are cached
COPY src ./src

# Package the application (-DskipTests - If want to skip tests to speed up)
RUN mvn clean package

# ---- Stage 2: Final Image ----
FROM eclipse-temurin:17-jdk-jammy as runtime

# Create a non-root user (optional best practice)
RUN useradd -m springuser

# Set working directory inside runtime container
WORKDIR /app

# Copy only the built JAR file from builder stage
COPY --from=builder /build/target/demo-0.0.1-SNAPSHOT.jar app.jar

# Change ownership and reduce container privilege
RUN chown springuser:springuser /app && chmod 755 /app/app.jar
USER springuser

# Expose port and define how app is launched
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
