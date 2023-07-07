output "instance_dns_name" {
  description = "Public address of ec2 instance"
  value       = "${aws_instance.ec2_instance[0].public_dns}"
}
