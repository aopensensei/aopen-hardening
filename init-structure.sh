#!/usr/bin/env bash

# スクリプト実行場所をリポジトリルートに固定
cd "$(dirname "$0")"

echo "===> ディレクトリ作成..."
mkdir -p config \
         data \
         docs \
         scripts \
         phases/phase1 \
         phases/phase2/terraform \
         phases/phase3/ansible/playbooks \
         phases/phase3/ansible/inventory/group_vars \
         phases/phase3/ansible/inventory/host_vars \
         phases/phase3/ansible/roles

echo "===> ファイル作成..."
touch config/defaults.yml \
      config/env.sample \
      data/phase1_config.json \
      data/phase2_infra.json \
      data/phase3_setup.json \
      docs/README.md \
      scripts/deploy.sh \
      scripts/phase1_config.sh \
      scripts/phase2_infra.sh \
      scripts/phase3_setup.sh \
      scripts/cleanup.sh \
      .gitignore

# README.md に例として簡単なヘッダを書く（必要に応じて編集）
cat << 'EOF' > docs/README.md
# aopen-hardening

サーバ防護演習用の構築・管理リポジトリです。  
AnsibleやTerraformなどを利用し、以下のフェーズに沿って構成をデプロイします。

- フェーズ1: 全体構造の決定
- フェーズ2: ネットワーク／インフラの準備
- フェーズ3: サーバセットアップ

詳細は必要に応じて追記してください。
EOF

# .gitignore に一時ファイルや不要なファイルを追記（例）
cat << 'EOF' > .gitignore
# Ansible/Terraformなどで生成される一時ファイル例
*.tfstate
*.tfstate.backup
*.retry

# ディレクトリ例
data/*
!data/.gitkeep

# その他不要ファイル
.DS_Store
EOF

# 任意で data/ 下に空ファイルの代わりに .gitkeep を作成しておく場合
touch data/.gitkeep

echo "===> Git add & commit..."
git add .
git commit -m "Initial directory structure commit"

echo "完了しました。必要に応じて手動で 'git push -u origin main' を行ってください。"
