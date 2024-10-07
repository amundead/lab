pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')  // Jenkins credentials for Docker Hub
        DOCKER_IMAGE = "amundead/nginx-hello-world:v1.04"   // Docker image with tag
        KUBECONFIG = "/sysuser/Jenkins/k8s-dev/k3s.yaml"  // Path to your KUBECONFIG
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: "https://github.com/amundead/test-repo.git"  // Clone your GitHub repo
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'  // Build Docker image
            }
        }
        
        stage('Push Docker Image to Docker Hub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push $DOCKER_IMAGE'  // Push Docker image to Docker Hub
            }
        }
          stage('Update Deployment YAML') {
            steps {
                // Replace the placeholder with the actual Docker image name
                sh "sed -i 's|{{DOCKER_IMAGE}}|$DOCKER_IMAGE|g' /workspace/CI-Testing Repo Nginx (Agent any)/deploy-dev/deployment.yaml"
            }
        }

        stage('Deploy Application') {
            steps {
                sh "kubectl --kubeconfig=$KUBECONFIG apply -f /workspace/CI-Testing Repo Nginx (Agent any)/deploy-dev/deployment.yaml"  // Apply deployment.yaml from the deploy folder
            }
        }
        
        stage('Update Nginx Image in Kubernetes') {
            steps {
                sh "kubectl --kubeconfig=$KUBECONFIG set image deployment/nginx-deployment nginx=$DOCKER_IMAGE"  // Update the Nginx image in the Kubernetes deployment
            }
        }
    }
    
    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
