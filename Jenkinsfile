pipeline {
    agent any

    environment {
        HARBOR_REGISTRY = 'bakul.mod.gov.my'  // Harbor registry URL
        HARBOR_PROJECT = 'nginxzlib'  // Harbor project where image will be pushed
        HARBOR_IMAGE = 'nginxzlib'
        IMAGE_NAME_HARBOR = "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_IMAGE}"  // Full image name for Harbor
        TAG = 'v1.00'  // Tag for the Docker image
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the source code from your repository 
                git branch: 'main', url: "https://github.com/amundead/test-repo.git"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using docker.build with --no-cache option
                    docker.build("${IMAGE_NAME_HARBOR}:${TAG}", "--no-cache .")
                }
            }
        }

        stage('Tag and Push Docker Image to Harbor') {
            steps {
                script {
                    // Use docker.withRegistry for secure login and push to Harbor
                    docker.withRegistry("https://${HARBOR_REGISTRY}", 'harbor-credentials-id') {
                        docker.image("${IMAGE_NAME_HARBOR}:${TAG}").push()
                    }
                }
            }
        }

        stage('Clean up') {
            steps {
                script {
                    // Remove unused Docker images to free up space
                    sh "docker rmi ${IMAGE_NAME_HARBOR}:${TAG}"
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace after the pipeline
            cleanWs()
        }
    }
}
