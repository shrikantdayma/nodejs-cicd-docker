pipeline {
    // Run the entire pipeline inside a Docker container with Node.js
    agent {
        docker {
            image 'node:18' // ✅ Includes Node.js and npm
            args '-v /var/run/docker.sock:/var/run/docker.sock' // ✅ Mount Docker socket so we can build images
        }
    }

    environment {
        DOCKER_IMAGE_NAME = 'nodejs-cicd-app'
        DOCKER_REGISTRY   = 'shrikantdayma'
        IMAGE_TAG         = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
        IMAGE_LATEST      = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest"
        CONTAINER_NAME    = 'nodejs-cicd-container'
    }

    stages {
        stage('Preparation & Checkout') {
            steps {
                echo 'Starting CI/CD pipeline...'
                // Code is automatically checked out in Declarative pipelines
            }
        }

        stage('Install & Test') {
            steps {
                echo 'Installing Node dependencies...'
                sh 'npm install'

                echo 'Running tests...'
                sh 'npm test' // This will work if test script is defined in package.json
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_TAG} ${IMAGE_LATEST}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Pushing images to ${DOCKER_REGISTRY}..."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USR',
                    passwordVariable: 'DOCKER_PSW')]) {

                    sh "echo ${DOCKER_PSW} | docker login -u ${DOCKER_USR} --password-stdin"
                    sh "docker push ${IMAGE_TAG}"
                    sh "docker push ${IMAGE_LATEST}"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                echo "Deploying the container: ${CONTAINER_NAME}"
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker run -d --name ${CONTAINER_NAME} -p 3000:3000 ${IMAGE_LATEST}"
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Build status: ${currentBuild.result}"
        }
        success {
            echo '✅ Deployment successful! Check the app at http://<Your-Jenkins-Host-IP>:3000'
        }
        failure {
            echo '❌ Deployment FAILED. Check console log for errors.'
        }
    }
}

