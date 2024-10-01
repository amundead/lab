pipeline {
    agent any

    environment {
        GITHUB_OWNER = 'amundead'  // Your GitHub username or organization
        GITHUB_REPOSITORY = 'test-repo'  // The repository where the package will be hosted
        IMAGE_NAME = "ghcr.io/${GITHUB_OWNER}/${GITHUB_REPOSITORY}"  // Full image name for GitHub Packages
        TAG = 'v1.02'  // Tag for the Docker image
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the source code from your repository using credentials securely
                git branch: 'main', url: "https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY}.git", credentialsId: 'github-credentials-id'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using docker.build
                    docker.build("${IMAGE_NAME}:${TAG}")
                }
            }
        }

        stage('Push Docker Image to GitHub Packages') {
            steps {
                script {
                    // Use docker.withRegistry for secure login and push
                    docker.withRegistry('https://ghcr.io', 'github-credentials-id') {
                        docker.image("${IMAGE_NAME}:${TAG}").push()
                    }
                }
            }
        }

        stage('Clean up') {
            steps {
                script {
                    // Remove unused Docker images to free up space
                    sh "docker rmi ${IMAGE_NAME}:${TAG}"
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
