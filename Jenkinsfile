pipeline {
    // We run the pipeline on any available Jenkins agent
    agent any 

    // Define environment variables for the Docker image path
    environment {
        DOCKER_IMAGE_NAME = 'nodejs-cicd-app'
        // *** This is where your username is used! ***
        DOCKER_REGISTRY   = 'shrikantdayma' 
        // Create a unique tag using the Jenkins Build Number
        IMAGE_TAG         = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
        IMAGE_LATEST      = "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest"
        CONTAINER_NAME    = 'nodejs-cicd-container'
    }

    stages {
        stage('Preparation & Checkout') {
            steps {
                echo 'Starting CI/CD pipeline...'
                // The source code is checked out implicitly at the start
            }
        }
        
        stage('Install & Test') {
            steps {
                echo 'Installing Node dependencies...'
                // Install dependencies
                sh 'npm install'
                
                echo 'Running tests...'
                // Run tests (adjust the script in package.json for real tests)
                sh 'npm test' 
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_TAG}"
                // Build the image and tag it with the specific BUILD_NUMBER
                sh "docker build -t ${IMAGE_TAG} ."
                // Also tag it as 'latest'
                sh "docker tag ${IMAGE_TAG} ${IMAGE_LATEST}"
            }
        }
        
        stage('Push to Docker Hub') {
            // Assumes you have a 'dockerhub-credentials' secret set up in Jenkins
            steps {
                echo "Pushing images to ${DOCKER_REGISTRY}..."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials', 
                    usernameVariable: 'DOCKER_USR', 
                    passwordVariable: 'DOCKER_PSW')]) {
                    
                    // 1. Log in to Docker Hub
                    sh "docker login -u ${DOCKER_USR} -p ${DOCKER_PSW}"
                    
                    // 2. Push the tagged image (e.g., shrikantdayma/nodejs-cicd-app:5)
                    sh "docker push ${IMAGE_TAG}"
                    
                    // 3. Push the 'latest' tag
                    sh "docker push ${IMAGE_LATEST}"
                }
            }
        }
        
        stage('Deploy Container') {
            steps {
                echo "Deploying the container: ${CONTAINER_NAME}"
                // Stop and remove the old container instance
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                
                // Run the new container, mapping internal port 3000 to host port 3000
                sh "docker run -d --name ${CONTAINER_NAME} -p 3000:3000 ${IMAGE_LATEST}"
            }
        }
    }
    
    post {
        always {
            echo "Pipeline finished. Build status: ${currentBuild.result}"
        }
        success {
            echo 'Deployment successful! Check the app at http://<Your-Jenkins-Host-IP>:3000'
        }
        failure {
            echo 'Deployment FAILED. Check console log for Docker errors.'
        }
    }
}
