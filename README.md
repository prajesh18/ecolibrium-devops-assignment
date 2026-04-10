# ecolibrium-devops-assignment
This project demonstrates an end-to-end DevOps pipeline:

- Infrastructure provisioning using Terraform (AWS VPC + EKS)
- Application deployment using Helm on EKS
- CI/CD automation using Jenkins
- Docker image build and push to ECR

## Design Decision

For this assignment, Terraform modules were intentionally not used.

The goal was to keep all infrastructure components explicit and easily reviewable, since this is an evaluation of core Terraform and AWS understanding.

In a production environment, the same setup would be modularized (VPC, EKS, IAM) for reusability, scalability, and team collaboration.


# End-to-End DevOps Pipeline on AWS (Terraform + Jenkins + EKS + Helm)

This project demonstrates a **fully automated DevOps pipeline** where a single Jenkins build:

- Provisions AWS infrastructure using Terraform (VPC, subnets, NAT, EKS, node groups)
- Builds Docker image and pushes to Amazon ECR
- Deploys application to EKS using Helm
- Exposes application via NGINX Ingress

---

# Architecture

Jenkins → Terraform → AWS (EKS)  
Jenkins → Docker → ECR  
Jenkins → Helm → Kubernetes (EKS)  
Ingress → Service → Pods  

---

# Prerequisites

- AWS Account
- IAM user with programmatic access
- Key pair for EC2
- Basic Linux knowledge

---

# Step 1: Launch EC2 (Jenkins Server)

- AMI: Amazon Linux 2
- Instance Type: c7i-flex.large (free tier eligible)
- Security Group:
  - Port 22 (SSH)
  - Port 8080 (Jenkins)

---

# Step 2: Install Required Tools

## SSH into EC2 and run:

## Install Java (Required for Jenkins):

sudo yum install java-17-amazon-corretto -y

## Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

## Install Docker

sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

## Install AWS CLI

sudo yum install -y awscli

## Install Terraform

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install terraform -y

## Install kubectl

curl -o kubectl https://amazon-eks.s3.ap-south-1.amazonaws.com/1.29.0/2024-01-04/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

## Install Helm

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Step 3: Configure AWS Access
aws configure

## Provide:

Access Key
Secret Key
Region: ap-south-1

# Step 4: Create ECR Repository
aws ecr create-repository \
  --repository-name ecolibrium-app \
  --region ap-south-1
  
# Step 5: Setup Jenkins

Access Jenkins:

http://<EC2-PUBLIC-IP>:8080

Setup Steps:
Unlock Jenkins
Install suggested plugins
Create Pipeline Job
Connect GitHub repo (Public repo → No credentials required)

# Step 6: Configure Jenkins Pipeline
Use the provided Jenkinsfile from the repository
No GitHub credentials required (public repo)

 # Step 7: Run the Pipeline

Trigger the build.

## What happens automatically:
### Terraform provisions:
VPC
Subnets
NAT Gateway
EKS Cluster
Node Group
Docker image is built and pushed to ECR
kubeconfig is configured
Application is deployed using Helm
Ingress controller is installed

# Step 8: Access Application

Get Ingress LoadBalancer:

kubectl get svc -n ingress-nginx

Update /etc/hosts (Windows or Linux):

<LOAD_BALANCER_IP> ecolibrium.local

Access:

http://ecolibrium.local

## How Jenkins Gets AWS Permissions

Jenkins runs Terraform and AWS commands using:

### IAM credentials configured via:

aws configure

These credentials allow:

Provisioning infrastructure (Terraform)
Pushing images to ECR
Managing EKS cluster

# Verification

kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A

Access http://ecolibrium.local
