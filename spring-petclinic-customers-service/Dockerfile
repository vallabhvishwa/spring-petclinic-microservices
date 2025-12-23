# STAGE 1: The Build Stage (Heavy)
# We use a full Maven image to compile the code
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the pom.xml first to cache dependencies (this makes future builds faster)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the source code and build the JAR
COPY src ./src
RUN mvn clean package -DskipTests

# STAGE 2: The Runtime Stage (Light/Prod-Grade)
# We switch to a tiny JRE image. No Maven, no source code, just Java.
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy ONLY the finished .jar from the first stage
COPY --from=build /app/target/*.jar app.jar

# Standard production port for this service
EXPOSE 8081

# Optimize Java for containers (Memory management)
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
