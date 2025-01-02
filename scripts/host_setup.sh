#!/usr/bin/env bash
#
# host-setup.sh
#
# デプロイ元ホストの環境をセットアップするスクリプト
# (UbuntuなどのDebian系OSを前提)
#
set -e

echo "========================================="
echo " AOPEN-HARDENING HOST SETUP SCRIPT"
echo "========================================="
echo

# パッケージリスト更新
echo "===> apt-get update ..."
sudo apt-get update -y

# 基本ツールのインストール
# (gnupg, software-properties-common を含む)
echo
echo "===> インストール: 基本ツール (gnupg, software-properties-common, iptablesなど)"
sudo apt-get install -y \
  gnupg \
  software-properties-common \
  iptables \
  curl \
  wget

# Ansible のインストール (抜けている可能性があるため)
echo
echo "===> インストール: ansible"
sudo apt-get install -y ansible

# jq のインストール (抜けている可能性があるため)
echo
echo "===> インストール: jq"
sudo apt-get install -y jq

# snap を利用した yq のインストール
echo
echo "===> インストール: yq (snap 経由)"
if ! command -v snap >/dev/null 2>&1; then
  echo "snap が見つかりません。snap をインストールします。"
  sudo apt-get install -y snapd
fi
sudo snap install yq

# openvpn, easy-rsa のインストール
echo
echo "===> インストール: openvpn, easy-rsa"
sudo apt-get install -y openvpn easy-rsa
echo "===> easy-rsa のシンボリックリンクを作成します..."
if [[ ! -x /usr/local/bin/easyrsa ]]; then
  sudo ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin/easyrsa
fi

# Terraform のインストール
echo
echo "===> インストール: terraform"
# HashiCorp公式リポジトリの追加
if [[ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]]; then
  echo "===> Terraform用のGPG鍵を追加します..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
else
  echo "Terraform用のGPG鍵は既に存在します。スキップします。"
fi

if [[ ! -f /etc/apt/sources.list.d/hashicorp.list ]]; then
  echo "===> Terraform用リポジトリを追加します..."
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
else
  echo "Terraform用リポジトリは既に存在します。スキップします。"
fi

sudo apt-get update -y
sudo apt-get install -y terraform

# AWS CLI のインストール
echo
echo "===> インストール: awscli"
sudo apt-get install -y awscli

echo
echo "========================================="
echo " SETUP COMPLETE!"
echo "========================================="
