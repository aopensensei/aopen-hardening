#!/usr/bin/env bash
# phase2_infra.sh

set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PHASE1_DATA="$PROJECT_ROOT/workspace/phase1_config.json"
WORKSPACE_TF="$PROJECT_ROOT/workspace/terraform"

if [[ ! -f "$PHASE1_DATA" ]]; then
  echo "===> フェーズ1の設定ファイルが見つかりません。"
  exit 1
fi

PRESET=$(jq -r '.selected_preset' "$PHASE1_DATA")
echo "===> 選択プリセットは: $PRESET"

# テンプレートの場所をプリセットごとに切り替え
TEMPLATE_DIR="$PROJECT_ROOT/template/phase2/$PRESET"
if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "===> テンプレートディレクトリが見つかりません: $TEMPLATE_DIR"
  exit 1
fi

# Terraform用ディレクトリを初期化
rm -rf "$WORKSPACE_TF"
mkdir -p "$WORKSPACE_TF"

echo "===> テンプレート($PRESET)をコピーしています..."
cp -r "$TEMPLATE_DIR/"* "$WORKSPACE_TF/"

cd "$WORKSPACE_TF"
echo "===> Terraform初期化..."
terraform init

echo "===> Terraformを適用 (apply)..."
terraform apply -auto-approve

echo "===> フェーズ2が完了しました。"
