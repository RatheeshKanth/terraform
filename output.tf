output "public_ip" {
    value = aws_eip.testElasticIP.public_ip
}