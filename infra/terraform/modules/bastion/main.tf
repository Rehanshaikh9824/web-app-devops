data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = var.ssh_public_key
  tags       = var.tags
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = aws_key_pair.bastion.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y kubectl aws-cli
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    mv /tmp/eksctl /usr/local/bin
    aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}
  EOF

  tags = merge(var.tags, { Name = "${var.project_name}-bastion" })
}

output "bastion_public_ip"  { value = aws_instance.bastion.public_ip }
output "bastion_instance_id"{ value = aws_instance.bastion.id }

variable "project_name"    { type = string }
variable "public_subnet_id"{ type = string }
variable "bastion_sg_id"   { type = string }
variable "ssh_public_key"  { type = string }
variable "cluster_name"    { type = string }
variable "aws_region"      { type = string }
variable "tags"            { type = map(string); default = {} }
