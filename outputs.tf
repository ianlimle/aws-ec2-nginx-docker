output "ec2_public_ip" {
    value = module.myapp-server.ec2_instance.public_ip
}