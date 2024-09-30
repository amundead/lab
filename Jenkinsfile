pipeline {
    agent {
        label 'docker-jenkins-agent'  // Use the Docker template label
        
    }

    environment {
        GITHUB_CREDENTIALS = credentials('github-credentials-id')  // Jenkins credential ID for GitHub credentials (username/token)
        GITHUB_OWNER = 'amundead'  // Your GitHub username or organization
        GITHUB_REPOSITORY = 'test-repo'  // The repository where the package will be hosted
        IMAGE_NAME = "ghcr.io/${GITHUB_OWNER}/${GITHUB_REPOSITORY}"  // Full image name for GitHub Packages
        TAG = '1.00'  // Tag for the Docker image
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the source code from your repository
                git branch: 'main', url: "https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY}.git"
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
                    // Log in to GitHub Packages using password stdin for security
                    sh "echo ${GITHUB_CREDENTIALS_PSW} | docker login ghcr.io -u ${GITHUB_CREDENTIALS_USR} --password-stdin"
                    // Push Docker image to GitHub Packages
                    sh "docker push ${IMAGE_NAME}:${TAG}"
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