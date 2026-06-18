FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app
# 假設你已經在本地執行過 ./mvnw package 產生了 jar 檔
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]