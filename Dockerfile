# STAGE 1: Build Stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
# Fix for Mac M4 SVE bug
ENV JAVA_OPTS="-XX:UseSVE=0" 
WORKDIR /app

# 1. Copy the ROOT pom
COPY pom.xml .

# 2. Copy ALL module poms so Maven understands the family tree
# We must include every folder that has a pom.xml
COPY spring-petclinic-admin-server/pom.xml spring-petclinic-admin-server/
COPY spring-petclinic-api-gateway/pom.xml spring-petclinic-api-gateway/
COPY spring-petclinic-config-server/pom.xml spring-petclinic-config-server/
COPY spring-petclinic-customers-service/pom.xml spring-petclinic-customers-service/
COPY spring-petclinic-discovery-server/pom.xml spring-petclinic-discovery-server/
COPY spring-petclinic-vets-service/pom.xml spring-petclinic-vets-service/
COPY spring-petclinic-visits-service/pom.xml spring-petclinic-visits-service/
COPY spring-petclinic-genai-service/pom.xml spring-petclinic-genai-service/

# 3. Download dependencies (this is the step that was failing)
# -fn (fail-never) ensures it keeps going even if a tiny plugin is missing
RUN mvn dependency:go-offline -B -fn

# 4. Now copy all the source code
COPY . .

# 5. Build only the specific service passed via --build-arg
ARG SERVICE_NAME
RUN mvn clean package -pl ${SERVICE_NAME} -am -DskipTests

# STAGE 2: Runtime Stage
FROM eclipse-temurin:17-jre
WORKDIR /app
ARG SERVICE_NAME

# Copy the specific JAR we just built
COPY --from=build /app/${SERVICE_NAME}/target/*.jar app.jar

# Standardized entrypoint
ENTRYPOINT ["java", "-jar", "app.jar"]
