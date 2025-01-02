##################################################
# Client VPN Endpoint
##################################################

# VPNサーバー証明書の設定
resource "aws_acm_certificate" "vpn_server_cert" {
  certificate_body  = file(var.vpn["path_cert_srv"])
  private_key       = file(var.vpn["path_prikey_srv"])
  certificate_chain = file(var.vpn["path_cert_ca"])
}

# CloudWatchロググループ（オプション）
resource "aws_cloudwatch_log_group" "vpn_log_group" {
  name = var.vpn["log_group"]

  tags = {
    Name = "VPN Log Group"
  }
}

# Client VPN Endpointの作成
resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
  description            = "Client VPN Endpoint"
  server_certificate_arn = aws_acm_certificate.vpn_server_cert.arn

  authentication_options {
    type                      = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_server_cert.arn
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn_log_group.name
  }

  transport_protocol    = "udp"
  vpn_port              = 443
  split_tunnel          = true
  client_cidr_block     = var.vpn["cidr"] # VPNクライアント用CIDR
  dns_servers           = ["8.8.8.8"]

  tags = {
    Name = "Client VPN Endpoint"
  }
}

# サブネットとの関連付け
resource "aws_ec2_client_vpn_network_association" "vpn_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = aws_subnet.main_subnet.id

  tags = {
    Name = "VPN Association"
  }
}

# 承認ルール
resource "aws_ec2_client_vpn_authorization_rule" "vpn_authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  target_network_cidr     = "10.1.0.0/16" # VPCのCIDRブロック
  authorize_all_groups    = true

  description = "Allow All Access"
}
