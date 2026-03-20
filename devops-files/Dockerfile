# Use AWS-supported OpenJDK
FROM amazoncorretto:8

EXPOSE 8080

COPY target/devops-integration.jar app.jar

ENTRYPOINT ["java","-jar","/app.jar"]