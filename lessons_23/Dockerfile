FROM openjdk
VOLUME /tmp
COPY target/*.jar myapp.jar
ENTRYPOINT ["java","-jar","/myapp.jar"]