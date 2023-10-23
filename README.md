# Terraform x Bash Script to install and setup Kubernetes Cluster on AWS with EC2

This project uses Terraform to automate the provisioning of a Kubernetes cluster on AWS using EC2 instances. It provides an easy way to deploy a scalable and flexible Kubernetes cluster for your applications.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [License](#license)

## Prerequisites

Before you begin, ensure that you have the following tools and accounts set up:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- AWS account with access keys and necessary permissions.
- SSH key pair for connecting to EC2 instances.


## Usage
1. **Customize the Configuration**:
    - Edit some variables for all file `main.tf`, `variables.tf`, and `outputs.tf` to match your infrastructure requirements.
2. **Initialize Terraform**:
    - Go to Directory that have main.tf is the same level with this file README.md
    - Run the following command to initialize Terraform:
        ```sh
        terraform init
    - Review and Plan:
        ```sh 
        terraform plan
    - Apply Configuration:
        ```sh 
        terraform apply
    - Destroy Resources:
        ```sh 
        terraform destroy
3. **Running bash script**:
    - Copy script `setup_k8s_master_for_root.sh` and run this script as root for Master node to Install Kubenetes Cluster
    - After run script `setup_k8s_master_for_root.sh` then copy script `setup_k8s_master_for_ubuntu.sh` and run this script as ubuntu for Master node
    - Copy script `setup_k8s_worker_for_root.sh` for Worker node to Install Kubenetes Cluster
    - After run all script successfull, please reboot server to change with new hostname
4. **Check Kubernetes Cluster as Master Node:
    - Login on Master Node and run this command:
        ```sh
        kubeclt get no -o wide
     
## LICENSE

This project is licensed under the MIT License - see the LICENSE file for details.