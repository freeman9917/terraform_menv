
output "vpc_id" {
    value = aws_vpc.my-tr-vpc.id
}

output "pub1_subnet_id" {
    value = aws_subnet.my-tr-vpc-public1.id
}

output "pub2_subnet_id" {
    value = aws_subnet.my-tr-vpc-public2.id
}


output "sec_group_id" {
    value = aws_security_group.myapp-sg.id
}

