#!/usr/bin/env bash
#
# deploy.sh
# 対話式でフェーズを実行するメインスクリプト
#
# 実行時は sudo はつけない想定です。
# 内部で sudo が必要な処理は各フェーズスクリプト内で実行してください。
# ---------------------------------------------------------

set -e

# プロジェクトルート (aopen-hardening)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "============================="
echo " AOPEN-HARDENING DEPLOY TOOL"
echo "============================="
echo



echo
echo "どのフェーズを実行しますか？"
echo "  1) フェーズ1 (全体構造の決定)"
echo "  2) フェーズ2 (ネットワーク／インフラの準備)"
echo "  3) フェーズ3 (サーバセットアップ)"
echo "  a) 全フェーズを順番に実行"
echo "  s) スキップ (何もせず終了)"
echo

read -p "選択してください (1/2/3/a/s): " phase_choice
echo

case "$phase_choice" in
  1)
    echo "===> フェーズ1を実行します..."
    bash "$PROJECT_ROOT/scripts/phase1_config.sh"
    ;;
  2)
    echo "===> フェーズ2を実行します..."
    bash "$PROJECT_ROOT/scripts/phase2_infra.sh"
    ;;
  3)
    echo "===> フェーズ3を実行します..."
    bash "$PROJECT_ROOT/scripts/phase3_setup.sh"
    ;;
  a)
    echo "===> フェーズ1 -> フェーズ2 -> フェーズ3 を順次実行し ます..."
    bash "$PROJECT_ROOT/scripts/phase1_config.sh"
    bash "$PROJECT_ROOT/scripts/phase2_infra.sh"
    bash "$PROJECT_ROOT/scripts/phase3_setup.sh"
    ;;
  s|S)
    echo "===> スキップして終了します。"
    exit 0
    ;;
  *)
    echo "無効な選択です。終了します。"
    exit 1
    ;;
esac

echo
echo "============================="
echo " デプロイが完了しました。"
echo "============================="
