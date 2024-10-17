FROM openjdk:17-jdk AS builder

WORKDIR /workspace

RUN apt-get update && apt-get install -y xargs

COPY . .

RUN ./gradlew clean build

COPY /build/libs/*SNAPSHOT.jar application.jar

RUN java -Djarmode=layertools -jar application.jar extract

FROM openjdk:17-jdk

WORKDIR /application

COPY --from=builder /workspace/dependencies/ .

COPY --from=builder /workspace/spring-boot-loader/ .

COPY --from=builder /workspace/snapshot-dependencies/ .

COPY --from=builder /workspace/application/ .

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]


