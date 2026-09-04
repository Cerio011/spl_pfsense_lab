output "instance_public_ip" {
  value = aws_instance.lab_ec2.public_ip
}

output "vpc_id" {
  value = data.aws_vpc.existing.id
}