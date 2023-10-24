provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

module "custom_vpc" {
  source         = "./modules/tf-vpc"
  prefix         = var.environment_name
  separator      = "-"
  name           = "axyres"
  vpc_cidr_block = var.vpc_cidr_block
  allowed_ip     = var.myip
  subnet_cidr    = var.subnet_cidr
}


resource "aws_instance" "k8s-master" {
    ami = var.ami
    key_name = var.instance_key 
    instance_type  = var.instance_type
    associate_public_ip_address = true
    subnet_id = module.custom_vpc.subnet_ids
    security_groups = [module.custom_vpc.security_group_id]

    tags = {
        Name = "${var.instance_name}_K8S_MASTER"
    }
    root_block_device {
        volume_size = 50  # Size of the root volume in GB
        volume_type = "gp3"  # EBS volume type (General Purpose SSD)
        delete_on_termination = true  # Delete the volume when the instance is terminated
    }
}

resource "aws_instance" "k8s-worker-1" {
    ami = var.ami
    key_name = var.instance_key 
    instance_type  = var.instance_type
    associate_public_ip_address = true
    subnet_id = module.custom_vpc.subnet_ids
    security_groups = [module.custom_vpc.security_group_id]

    tags = {
        Name = "${var.instance_name}_K8S_WORKER_1"
    }
    root_block_device {
        volume_size = 50  # Size of the root volume in GB
        volume_type = "gp3"  # EBS volume type (General Purpose SSD)
        delete_on_termination = true  # Delete the volume when the instance is terminated
    }
}

#resource "aws_instance" "k8s-worker-2" {
#    ami = var.ami
#    key_name = var.instance_key 
#    instance_type  = var.instance_type
#    associate_public_ip_address = true
#    subnet_id = module.custom_vpc.subnet_ids
#    security_groups = [module.custom_vpc.security_group_id]
#
#    tags = {
#        Name = "${var.instance_name}_K8S_WORKER_1"
#    }
#    root_block_device {
#        volume_size = 50  # Size of the root volume in GB
#        volume_type = "gp3"  # EBS volume type (General Purpose SSD)
#        delete_on_termination = true  # Delete the volume when the instance is terminated
#    }
#}

