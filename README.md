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
