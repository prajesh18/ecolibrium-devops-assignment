pipeline {
    agent any

    options {
        timestamps()
    }

    environment {
        AWS_REGION = 'ap-south-1'
        CLUSTER_NAME = 'ecolibrium-eks'
        RELEASE_NAME = 'ecolibrium-app'
        ECR_REPO = '174435304246.dkr.ecr.ap-south-1.amazonaws.com/ecolibrium-app'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/prajesh18/ecolibrium-devops-assignment.git'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init -reconfigure -input=false
                    terraform plan -out=tfplan
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Wait for EKS') {
            steps {
                sh '''
                aws eks wait cluster-active --name $CLUSTER_NAME --region $AWS_REGION
                '''
            }
        }

        stage('Configure kubeconfig') {
            steps {
                sh '''
                aws eks update-kubeconfig \
                  --region $AWS_REGION \
                  --name $CLUSTER_NAME

                kubectl config current-context
                '''
            }
        }

        stage('Build & Push Image') {
            steps {
                dir('app') {
                    sh '''
                    docker build -t ecolibrium-app .

                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

                    docker tag ecolibrium-app:latest $ECR_REPO:latest

                    docker push $ECR_REPO:latest
                    '''
                }
            }
        }

        stage('Install Ingress Controller') {
            steps {
                sh '''
                kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

                helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
                helm repo update

                helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
                  --namespace ingress-nginx
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                dir('helm-chart/ecolibrium-app') {
                    sh '''
                    helm upgrade --install $RELEASE_NAME . \
                      --namespace default
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                kubectl get nodes
                kubectl get pods -A
                kubectl get svc -A
                kubectl get ingress -A
                '''
            }
        }
    }
    post {

        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Please check the logs.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

