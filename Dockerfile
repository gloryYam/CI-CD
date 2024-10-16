FROM openjdk:17-jdk as builder

WORKDIR /workspace

COPY . .

RUN ./gradlew clean build --no-daemon

COPY /build/libs/*SNAPSHOT.jar application.jar

RUN java -Djarmode=layertools -jar application.jar extract

FROM openjdk:17-jdk

WORKDIR /application

COPY --from=builder /workspace/dependencies/ .

COPY --from=builder /workspace/spring-boot-loader/ .

COPY --from=builder /workspace/snapshot-dependencies/ .

COPY --from=builder /workspace/application/ .

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]


