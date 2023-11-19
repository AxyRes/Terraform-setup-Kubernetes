output "associate_public_ip_address" {
  value = {
#    public_ip     = [ for v in aws_instance.k8s-cluster : v.public_ip]
    master_node   = aws_instance.k8s-master.public_ip
    worker_node_1 = aws_instance.k8s-worker-1.public_ip
    #worker_node_2 = aws_instance.k8s-worker-2.public_ip
  }
}