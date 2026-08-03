# ---- Build stage ----
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

# Copy wrapper and pom first to leverage Docker layer caching for dependencies
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Now copy source and build
COPY src/ src/
RUN ./mvnw clean package -DskipTests -B

# ---- Run stage ----
FROM eclipse-temurin:21-jre-alpine AS run

# Run as non-root user — never run app containers as root
RUN addgroup -S custodia && adduser -S custodia -G custodia

WORKDIR /app

COPY --from=build --chown=custodia:custodia /app/target/*.jar app.jar

USER custodia

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
  CMD wget -q --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]