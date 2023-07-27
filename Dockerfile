FROM openjdk:17-jdk-alpine as build

ENV MAVEN_VERSION 3.5.4
ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH

RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -zxvf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    rm apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv apache-maven-$MAVEN_VERSION /usr/lib/mvn

WORKDIR /workspace/app

COPY pom.xml .
COPY src src
RUN mvn install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM openjdk:17-jdk-alpine
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
# ENTRYPOINT ["java","-cp","app:app/lib/*","books.BooksApplication"]
ENTRYPOINT ["java","-cp","app:app/lib/*","com.mtnx.service.ServiceApplicationKt"]



# run via docker run -d -p 8080:8080 <image-id>
# http://localhost:8080/api/v1/campaigns

## SECTION TO BUILD WITH JIB ##
# ADD ./target/campaigns-0.0.1.jar /app/
# CMD ["java", "-Xmx200m", "-jar", "/app/campaigns.jar"]

# EXPOSE 8080