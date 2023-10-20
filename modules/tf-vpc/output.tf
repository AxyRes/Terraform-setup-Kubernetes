output "vpc_id" {
  value = aws_vpc.vpc_k8s.id
}

output "default_security_group_id" {
  value = aws_vpc.vpc_k8s.default_security_group_id
}

output "subnet_ids" {
  value = aws_subnet.subnet_k8s.id
}

output "security_group_id" {
  value = aws_security_group.vpc_sg_k8s.id
}