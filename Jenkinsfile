pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'nodejs-cicd-app'
        DOCKER_REGISTRY   = 'shrikantdayma' // Your GitHub/Docker Hub username
        IMAGE_TAG         = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
        IMAGE_LATEST      = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest"
        CONTAINER_NAME    = 'nodejs-cicd-container'
    }

    stages {
        stage('Preparation & Verification') {
            steps {
                echo 'Starting CI/CD pipeline and verifying workspace contents...'
                // Debug step to confirm files are checked out correctly
                sh "ls -R \$WORKSPACE" 
            }
        }
        
        // --- FINAL FIX: Running NPM directly on the Agent's shell ---
        // This stage relies on 'nodejs' and 'npm' being installed on the Jenkins agent.
        stage('Install & Test') {
            steps {
                echo 'Installing dependencies and running tests directly on Agent shell.'
                sh 'npm install'
                sh 'npm test' 
            }
        }
        // -------------------------------------------------------------

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_TAG}"
                // This relies on the 'docker' client being installed on the Jenkins agent.
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
            echo '✅ Deployment successful! Check the app at http://<Jenkins-Host-IP>:3000'
        }
        failure {
            echo '❌ Deployment FAILED. Check console log for errors.'
        }
    }
}

