# EC2インスタンスの設定 (web01)
variable "web01" {
  type = map(string)
  default = {
    tag                        = "web01"
    ami                        = "ami-0a0e5d9c7acc336f1" # Ubuntu 22.04 LTS us-east-1a
    instance_type              = "t2.medium"
    root_volume_type           = "gp2"
    root_volume_size           = "10"
    root_delete_on_termination = "true"
    private_ip                 = "10.1.1.10" # 固定IPアドレス
  }
}

# EC2インスタンスの設定 (web02)
variable "web02" {
  type = map(string)
  default = {
    tag                        = "web02"
    ami                        = "ami-0a0e5d9c7acc336f1" # 同じAMI IDを使用
    instance_type              = "t2.medium"
    root_volume_type           = "gp2"
    root_volume_size           = "10"
    root_delete_on_termination = "true"
    private_ip                 = "10.1.1.11" # 固定IPアドレス
  }
}

# EC2インスタンスの設定 (jumpbox)
variable "jumpbox" {
  type = map(string)
  default = {
    tag                        = "jumpbox"
    ami                        = "ami-0a0e5d9c7acc336f1" # Ubuntu 22.04 LTS us-east-1a
    instance_type              = "t2.micro"
    root_volume_type           = "gp2"
    root_volume_size           = "10"
    root_delete_on_termination = "true"
    private_ip                 = "10.1.1.201" # 固定IPアドレス
  }
}

# EC2インスタンスの設定 (cli01)
variable "cli01" {
  type = map(string)
  default = {
    tag                        = "cli01"
    ami                        = "ami-0a0e5d9c7acc336f1" # Windows Server AMI
    instance_type              = "t2.medium"
    root_volume_type           = "gp2"
    root_volume_size           = "30"
    root_delete_on_termination = "true"
    private_ip                 = "10.1.1.101" # 固定IPアドレス
  }
}

# 管理アカウントとパスワード
variable "root_password" {
  default = "AdminP@ssw0rd!"
}
