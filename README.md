# DevOps Project

![Project Overview](https://github.com/user-attachments/assets/06671ff1-1f03-4e45-bc76-b835d6de3b0e)

This repository contains a comprehensive DevOps setup for deploying a Java application using infrastructure as code, continuous integration, and continuous deployment pipelines. The project leverages Terraform for infrastructure provisioning, Jenkins for CI/CD, Docker for containerization, and Kubernetes for orchestration.

## Table of Contents

- [Components](#components)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [CI/CD Pipeline](#cicd-pipeline)
- [Automation](#automation)
- [Usage](#usage)

## Components

- **Simple Java Code**: Sample Java application for demonstration.
- **Dockerfile**: Containerization configuration for the Java application.
- **Kubernetes Manifests**: Deployment and service configurations (`deployment.yaml` and `service.yaml`).
- **Jenkinsfile**: Pipeline scripts for CI and CD processes.
- **Terraform Code**: Infrastructure provisioning scripts for AWS EC2 instances.

## Prerequisites

- AWS Account with appropriate permissions.
- GitHub repository for source code.
- Docker Hub account.
- Basic knowledge of AWS, Jenkins, Docker, and Kubernetes.

## Setup Instructions

### 1. Provision Infrastructure with Terraform

Create two EC2 instances: 'Master-Server' and 'Node-Server'.

- **Master-Server**: Install Java, Jenkins, Maven, Docker, Ansible, and Trivy.
- **Node-Server**: Install Docker, Kubeadm, and Kubernetes.

Run the Terraform scripts in the `terraform-files/` directory to provision the instances.

### 2. Establish Passwordless SSH Connection

#### On Node-Server:
```bash
sudo su -
passwd ec2-user  # Set a password for ec2-user
vi /etc/ssh/sshd_config  # Set 'PermitRootLogin yes' and 'PasswordAuthentication yes'
service sshd restart
```

#### On Master-Server:
```bash
ssh-keygen  # Generate SSH key (press Enter for defaults)
ssh-copy-id ec2-user@<Node_Private_IP>  # Copy key to Node-Server (enter 'yes' and password when prompted)
```

### 3. Configure Jenkins Credentials

Access the Jenkins portal and add the following credentials under **Manage Jenkins > Credentials > System > Global credentials**:

- **Docker Hub Credentials**: Username and password (use 'Secret text' type).
- **K8s Server Credentials**: SSH username with private key for the Node-Server.
- **GitHub Credentials**: Username and personal access token (generate from GitHub Settings > Developer settings > Personal access tokens).
- **Docker Hub Token** (optional): Token from Docker Hub Account Settings > Security.

### 4. Install Required Jenkins Plugins

Install the 'SSH Agent' plugin via **Manage Jenkins > Plugins > Available plugins**.

## CI/CD Pipeline

### Continuous Integration (CI) Pipeline

1. In Jenkins, create a new pipeline job.
2. Paste the CI pipeline code from `Jenkinsfile-CI`.
3. Run the pipeline to build, test, and containerize the application.

### Continuous Deployment (CD) Pipeline

1. Create another pipeline job for CD.
2. Set environment variables: Pipeline name, Project name, and Node-Server private IP.
3. Run the pipeline to deploy the application to Kubernetes.
4. Access the application via `<Node_Server_Public_IP>:<NodePort_No>`.

## Automation

### Automate CD after CI Success

In the CD pipeline configuration:
- Go to **Build Triggers**.
- Select "Build after other projects are built".
- Enter the CI pipeline name.
- Check "Trigger only if build is stable".
- Save.

### Automate CI on GitHub Push

1. In Jenkins CI pipeline:
   - **Configure > Build Triggers > GitHub hook trigger for GITScm polling**.
2. Generate a Jenkins API token: **User > Configure > API Tokens**.
3. In GitHub repository:
   - **Settings > Webhooks > Add webhook**.
   - Payload URL: `<Jenkins_URL>:8080/github-webhook/`.
   - Content type: `application/json`.
   - Secret: Use the Jenkins API token.

## Usage

1. Push changes to the GitHub repository to trigger the CI pipeline.
2. Upon successful CI, the CD pipeline will automatically deploy the application.
3. Monitor the deployment through Jenkins and access the application via the Node-Server's public IP and NodePort.

For detailed configurations, refer to the respective files in the repository. -->
    Content type: json;     Secret: <Jenkins-API-Token> --> Add Webhook
    (Try making any changes in your code & the pipeline should automatically trigger)
8. Deletion
 a. Run the below command in Terraform to destroy the entire infrastructure
    terraform destroy --auto-approve
