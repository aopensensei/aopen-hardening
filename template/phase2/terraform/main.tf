# インターネットゲートウェイの作成
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# ルートテーブルの作成
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# サブネットにルートテーブルを関連付け
resource "aws_route_table_association" "main_subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# VPCの作成
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# サブネットの設定（パブリックIPの割り当てを許可）
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true # インスタンス作成時にパブリッ クIPを割り当て
  tags = {
    Name = "main-subnet"
  }
}

# セキュリティグループの作成
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# SSHキーを生成
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# AWSにSSHキーペアを登録
resource "aws_key_pair" "generated_key" {
  key_name   = "generated-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Web01インスタンスの作成
resource "aws_instance" "web01" {
  ami                    = var.web01["ami"]
  instance_type          = var.web01["instance_type"]
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = aws_subnet.main_subnet.id
  private_ip             = var.web01["private_ip"]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  root_block_device {
    volume_type           = var.web01["root_volume_type"]
    volume_size           = var.web01["root_volume_size"]
    delete_on_termination = var.web01["root_delete_on_termination"]
  }

  associate_public_ip_address = true # パブリックIPを割り当てる

  tags = {
    Name = var.web01["tag"]
  }
}

# Web02インスタンスの作成
resource "aws_instance" "web02" {
  ami                    = var.web02["ami"]
  instance_type          = var.web02["instance_type"]
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = aws_subnet.main_subnet.id
  private_ip             = var.web02["private_ip"]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  root_block_device {
    volume_type           = var.web02["root_volume_type"]
    volume_size           = var.web02["root_volume_size"]
    delete_on_termination = var.web02["root_delete_on_termination"]
  }

  associate_public_ip_address = true # パブリックIPを割り当てる

  tags = {
    Name = var.web02["tag"]
  }
}

# Jumpboxインスタンスの作成
resource "aws_instance" "jumpbox" {
  ami                    = var.jumpbox["ami"]
  instance_type          = var.jumpbox["instance_type"]
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = aws_subnet.main_subnet.id
  private_ip             = var.jumpbox["private_ip"]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  root_block_device {
    volume_type           = var.jumpbox["root_volume_type"]
    volume_size           = var.jumpbox["root_volume_size"]
    delete_on_termination = var.jumpbox["root_delete_on_termination"]
  }

  associate_public_ip_address = true # セットアップ時のみパブリ ックIPを割り当て

  tags = {
    Name = var.jumpbox["tag"]
  }
}

# ローカルに秘密鍵を保存
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/generated-key.pem"
}

# 出力設定
output "web01_private_ip" {
  value       = aws_instance.web01.private_ip
  description = "The private IP of web01."
}

output "web01_public_ip" {
  value       = aws_instance.web01.public_ip
  description = "The public IP of web01."
}

output "web02_private_ip" {
  value       = aws_instance.web02.private_ip
  description = "The private IP of web02."
}

output "web02_public_ip" {
  value       = aws_instance.web02.public_ip
  description = "The public IP of web02."
}

output "jumpbox_private_ip" {
  value       = aws_instance.jumpbox.private_ip
  description = "The private IP of the jumpbox."
}

output "jumpbox_public_ip" {
  value       = aws_instance.jumpbox.public_ip
  description = "The public IP of the jumpbox."
}
