#!/usr/bin/env bash
#
# phase1_task6_keygen.sh
# 鍵作成スクリプト (EasyRSA)
#
set -e

# 引数チェック
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <preset>"
  exit 1
fi

PRESET="$1"
EASYRSA_BASE="$HOME/easyrsa"
EASYRSA_CMD="/usr/share/easy-rsa/easyrsa"
KEYS_DIR="$(cd "$(dirname "$0")/.." && pwd)/workspace/keys"

if [[ "$PRESET" != "aopen-hardening" ]]; then
  echo "===> プリセット [$PRESET] では鍵作成はスキップされます。"
  exit 0
fi

echo "===> プリセット [$PRESET] では鍵が必要です。鍵作成を開始します。"

# EasyRSAディレクトリ準備
mkdir -p "$EASYRSA_BASE"

# PKIデータの確認と初期化
if [[ -d "$EASYRSA_BASE/pki" ]]; then
  echo "===> 既存のPKIデータが見つかりました: $EASYRSA_BASE/pki"
  read -p "再初期化しますか？ (既存データは削除されます) [y/N]: " reinit_pki
  reinit_pki="${reinit_pki:-N}"
  if [[ "$reinit_pki" =~ ^[Yy]$ ]]; then
    rm -rf "$EASYRSA_BASE/pki"
    mkdir -p "$EASYRSA_BASE"
    (cd "$EASYRSA_BASE" && "$EASYRSA_CMD" init-pki)
  fi
else
  echo "===> PKIデータを初期化します。"
  (cd "$EASYRSA_BASE" && "$EASYRSA_CMD" init-pki)
fi

# 鍵作成
echo "===> CA証明書を作成します (nopass)。"
(cd "$EASYRSA_BASE" && "$EASYRSA_CMD" build-ca nopass)

SERVER_CERT_NAME="server.carkn.local"
echo "===> サーバ証明書を作成します (nopass)。"
(cd "$EASYRSA_BASE" && "$EASYRSA_CMD" build-server-full "$SERVER_CERT_NAME" nopass)

CLIENT_CERT_NAME="client.carkn.local"
echo "===> クライアント証明書を作成します (nopass)。"
(cd "$EASYRSA_BASE" && "$EASYRSA_CMD" build-client-full "$CLIENT_CERT_NAME" nopass)

# 鍵ファイルをコピー
mkdir -p "$KEYS_DIR"
cp -v "$EASYRSA_BASE/pki/ca.crt"                        "$KEYS_DIR/ca.crt"
cp -v "$EASYRSA_BASE/pki/issued/$SERVER_CERT_NAME.crt"  "$KEYS_DIR/${SERVER_CERT_NAME}.crt"
cp -v "$EASYRSA_BASE/pki/private/$SERVER_CERT_NAME.key" "$KEYS_DIR/${SERVER_CERT_NAME}.key"
cp -v "$EASYRSA_BASE/pki/issued/$CLIENT_CERT_NAME.crt"  "$KEYS_DIR/${CLIENT_CERT_NAME}.crt"
cp -v "$EASYRSA_BASE/pki/private/$CLIENT_CERT_NAME.key" "$KEYS_DIR/${CLIENT_CERT_NAME}.key"

chmod 600 "$KEYS_DIR/"*.key

echo "===> 鍵作成が完了しました。"
