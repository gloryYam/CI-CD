pipeline {
    agent any

    environment {
        repository = "gloryyam/ci_cd"
        DOCKERHUB_CREDENTIALS = credentials('DockerHub-Credentials')
        IMAGE_TAG = ""
        SPRING_SERVER_IP = "54.180.212.28"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                git branch: 'main', url : "https://github.com/gloryYam/ci-cd"
            }
        }

        stage('Test') {
            steps {
                script {
                    sh "docker --version"
                    sh "docker compose --version"
                }
            }
        }

        stage('Set Image Tag') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        IMAGE_TAG = "1.0.${BUILD_NUMBER}"
                    } else {
                        IMAGE_TAG = "0.0.${BUILD_NUMBER}"
                    }
                    echo "Image tag set to: ${IMAGE_TAG}"
                }
            }
        }

         // gradlew 파일에 실행 권한 부여
                stage('Grant Execute Permission') {
                    steps {
                        script {
                            sh 'chmod +x ./gradlew'
                        }
                    }
                }

        // 새로운 빌드 단계 추가
        stage('Build JAR') {
            steps {
                script {
                    // Gradle 빌드를 통해 JAR 파일 생성
                    sh './gradlew clean build'
                }
            }
        }

        stage('Building Image') {
            steps {
                script {
                    // Docker 이미지를 빌드합니다
                    sh "docker build -t ${repository}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub-Credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                }
            }
        }

        stage('Deploy Image') {
            steps {
                sh "docker push ${repository}:${IMAGE_TAG}"
            }
        }

        stage('Deploy to Spring Server') {
            steps {
                sshagent (credentials: ['DeployServer_Private_Key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@${SPRING_SERVER_IP} ubuntu
                        scp
                }
            }
        }

        stage('Clean up') {
            steps {
                sh "docker rmi ${repository}:${IMAGE_TAG}"
            }
        }
    }

    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
            deleteDirs: true,
            disableDeferredWipeout: true,
            notFailBuild: true,
            patterns: [[pattern: '.gitignore', type: 'INCLUDE'], [pattern: '.propsfile', type: 'EXCLUDE']])
        }

        success {
            echo 'Build and deployment successfuldg'
        }
        failure{
            echo 'Build and deployment failed'
        }
    }
}
