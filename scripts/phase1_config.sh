#!/usr/bin/env bash
#
# phase1_config.sh
# フェーズ1: 全体構造の決定を行うスクリプト
#
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UTIL_SCRIPT="$PROJECT_ROOT/scripts/util/check_and_reuse_file.sh"

DEFAULTS_FILE="$PROJECT_ROOT/config/defaults.yml"
PHASE1_DATA="$PROJECT_ROOT/workspace/phase1_config.yml"

# ▼ フォールバック用のデフォルト値
DEFAULT_DEPLOY_TARGET="aws"
DEFAULT_SELECTED_PRESET="h2024c-practice"
DEFAULT_ADMIN_USER="admin"
DEFAULT_ADMIN_PASSWORD="admin123!"

echo "=================================="
echo " [ フェーズ1 ] 全体構造の決定"
echo "=================================="
echo

#
# (A) 中間ファイル(phase1_config.yml)がある場合に再利用を確認
#
"$UTIL_SCRIPT" "$PHASE1_DATA"
RESULT=$?

if [[ $RESULT -eq 0 ]]; then
  echo "===> 既存の $PHASE1_DATA を再利用します。"
  echo " (鍵生成や設定項目の入力はスキップします)"
  echo
  # 鍵作成スクリプトは必要に応じて呼び出すか検討
  exit 0
elif [[ $RESULT -eq 2 ]]; then
  echo "===> 新規作成を実行します..."
  # 破棄してファイルを削除した後、新規作成ロジックへ続行
fi
# ※ RESULT=1 は現状 check_and_reuse_file.sh では返らない想定
#   (編集後に再利用 => exit 0)

# ------------------------------------------------------------------
# (1) デフォルト値の読み込み
# ------------------------------------------------------------------
if command -v yq >/dev/null 2>&1; then
  if [[ -f "$DEFAULTS_FILE" ]]; then
    echo "===> defaults.yml を読み込みます: $DEFAULTS_FILE"
    DEFAULT_DEPLOY_TARGET="$(yq e '.phase1.deploy_target' "$DEFAULTS_FILE")"
    DEFAULT_SELECTED_PRESET="$(yq e '.phase1.selected_preset' "$DEFAULTS_FILE")"
    DEFAULT_ADMIN_USER="$(yq e '.phase1.admin_user' "$DEFAULTS_FILE")"
    DEFAULT_ADMIN_PASSWORD="$(yq e '.phase1.admin_password' "$DEFAULTS_FILE")"
  else
    echo "===> $DEFAULTS_FILE が見つかりません。フォールバックを使用します。"
  fi
else
  echo "===> yq がインストールされていません。フォールバックの値を使用します。"
fi

# ------------------------------------------------------------------
# (2) デプロイ対象を選択
# ------------------------------------------------------------------
echo
echo "デプロイ対象を選択してください。"
echo "  1) AWS"
echo "  2) Local (VirtualBoxなど)"
echo "   ※ デフォルト: $DEFAULT_DEPLOY_TARGET"
read -p "選択 (1/2) [1]: " deploy_choice
deploy_choice="${deploy_choice:-1}"

case "$deploy_choice" in
  1) DEPLOY_TARGET="aws" ;;
  2) DEPLOY_TARGET="local" ;;
  *) DEPLOY_TARGET="$DEFAULT_DEPLOY_TARGET" ;;
esac
echo "===> 選択されたデプロイ対象: $DEPLOY_TARGET"

# ------------------------------------------------------------------
# (3) 構成プリセットを選択
# ------------------------------------------------------------------
echo
echo "構成プリセットを選択してください。"
echo "  1) h2024c-practice"
echo "  2) aopen-hardening"
echo "   ※ デフォルト: $DEFAULT_SELECTED_PRESET"
read -p "選択 (1/2) [1]: " preset_choice
preset_choice="${preset_choice:-1}"

case "$preset_choice" in
  1) SELECTED_PRESET="h2024c-practice" ;;
  2) SELECTED_PRESET="aopen-hardening" ;;
  *) SELECTED_PRESET="$DEFAULT_SELECTED_PRESET" ;;
esac
echo "===> 選択された構成プリセット: $SELECTED_PRESET"

# ------------------------------------------------------------------
# (4) AWS向け準備（例）
# ------------------------------------------------------------------
if [[ "$DEPLOY_TARGET" == "aws" ]]; then
  echo
  echo "AWS向けの準備を行います..."
  # aws sts get-caller-identity 等のコマンドを実行する場合はここに
fi

# ------------------------------------------------------------------
# (5) 管理アカウントとパスワードの設定（オプション）
# ------------------------------------------------------------------
echo
echo "===> 管理用アカウント・パスワードの設定を行います。"
read -p "管理者アカウント名を入力してください [$DEFAULT_ADMIN_USER]: " admin_user
admin_user="${admin_user:-$DEFAULT_ADMIN_USER}"

read -sp "管理者パスワードを入力してください (未入力時はデフォルト): " admin_pass
echo
if [[ -z "$admin_pass" ]]; then
  admin_pass="$DEFAULT_ADMIN_PASSWORD"
fi

# ------------------------------------------------------------------
# (6) YAML形式でフェーズ1結果を出力
# ------------------------------------------------------------------
mkdir -p "$PROJECT_ROOT/workspace"
cat << EOF > "$PHASE1_DATA"
deploy_target: "$DEPLOY_TARGET"
selected_preset: "$SELECTED_PRESET"
admin_user: "$admin_user"
admin_password: "$admin_pass"
EOF

echo
echo "===> フェーズ1の設定を $PHASE1_DATA に保存しました。"
echo "    内容を確認・編集したい場合はファイルを直接修正してください。"

# ------------------------------------------------------------------
# (7) VPN等に利用する鍵を作成 (EasyRSA) - プリセットに応じて処理を分ける
# ------------------------------------------------------------------
"$PROJECT_ROOT/scripts/phase1_task6_keygen.sh" "$SELECTED_PRESET"

echo
echo "=================================="
echo " フェーズ1完了!"
echo "=================================="
