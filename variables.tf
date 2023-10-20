variable "environment_name" {
  default = "dev"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "instance_name" {
  default = "MISR_TEST"
}

variable "instance_key" {
  default = "MISR_KEY"
}

variable "ami" {
  default = "ami-078c1149d8ad719a7"
}

variable "vpc_cidr_block" {
  default = "10.50.0.0/16"
}

variable "subnet_cidr" {
  default = "10.50.20.0/24"
}

variable "myip" {
  default = "171.246.210.79/32"
}