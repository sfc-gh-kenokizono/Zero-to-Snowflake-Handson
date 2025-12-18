# Zero to Snowflake ハンズオン

<p align="center">
  <img src="https://www.snowflake.com/wp-content/themes/flavor/flavor/assets/img/logos/logo-white.svg" alt="Snowflake Logo" width="300">
</p>

Snowflakeの基本機能から高度なAI/ML機能、ガバナンスまでを体系的に学ぶハンズオン教材です。  
架空のフードトラック企業「**Tasty Bytes**」のデータを使用して、実践的なスキルを習得します。

---

## 📚 モジュール構成

| モジュール | 内容 | 所要時間（目安） |
|-----------|------|----------------|
| [00_setup](./00_setup/) | 環境セットアップ | 15分 |
| [01_getting_started](./01_getting_started/) | Snowflakeの基本操作 | 45分 |
| [02_data_pipelines](./02_data_pipelines/) | データパイプライン構築 | 45分 |
| [03_cortex_ai](./03_cortex_ai/) | Cortex AI SQL関数 | 30分 |
| [04_governance](./04_governance/) | Horizonによるガバナンス | 45分 |
| [05_apps_collaboration](./05_apps_collaboration/) | Marketplace・アプリ連携 | 30分 |

**合計所要時間**: 約3.5時間

---

## 🎯 学習目標

このハンズオンを完了すると、以下のスキルを習得できます：

### 基本スキル
- ✅ 仮想ウェアハウスの作成・管理・スケーリング
- ✅ クエリ結果キャッシュの活用
- ✅ ゼロコピークローンによる開発環境構築
- ✅ Time Travel（UNDROP）によるデータ復旧

### データエンジニアリング
- ✅ 外部ステージからのデータ取り込み
- ✅ 半構造化データ（VARIANT）の操作
- ✅ Dynamic Tablesによる宣言的パイプライン
- ✅ DAGによるデータフロー可視化

### AI/ML
- ✅ Cortex AI関数（SENTIMENT, AI_CLASSIFY, EXTRACT_ANSWER, AI_SUMMARIZE_AGG）
- ✅ 大規模データに対する自然言語分析

### ガバナンス・セキュリティ
- ✅ ロールベースアクセス制御（RBAC）
- ✅ 自動タグ付けによるデータ分類
- ✅ マスキングポリシー（列レベルセキュリティ）
- ✅ 行アクセスポリシー（行レベルセキュリティ）
- ✅ データメトリック関数（DMF）による品質監視

### コラボレーション
- ✅ Snowflake Marketplaceからのデータ取得
- ✅ 外部データとの統合分析

---

## 🚀 クイックスタート

### 前提条件

- Snowflakeアカウント（トライアルアカウント可）
- ACCOUNTADMIN ロールへのアクセス
- Webブラウザ（Chrome推奨）

### セットアップ手順

1. **Snowsightにログイン**
   - [app.snowflake.com](https://app.snowflake.com) にアクセス

2. **ワークシートを作成**
   - 左メニューから「Worksheets」を選択
   - 「+」ボタンで新規ワークシートを作成

3. **セットアップSQLを実行**
   - `00_setup/setup.sql` の内容をワークシートにコピー
   - 全体を選択して実行（約5-10分）

4. **各モジュールを順番に実行**
   - 01 → 02 → 03 → 04 → 05 の順番で進めてください

---

## 📁 フォルダ構成

```
Zero-to-Snowflake-Handson/
├── README.md                    # このファイル
├── INSTRUCTOR_GUIDE.md          # インストラクター向けガイド
│
├── 00_setup/                    # 環境セットアップ
│   ├── README.md
│   ├── setup.sql
│   └── cleanup.sql
│
├── 01_getting_started/          # モジュール1
│   ├── README.md
│   ├── getting_started.sql
│   ├── reset.sql
│   └── slides/
│
├── 02_data_pipelines/           # モジュール2
│   ├── README.md
│   ├── data_pipelines.sql
│   ├── reset.sql
│   └── slides/
│
├── 03_cortex_ai/                # モジュール3
│   ├── README.md
│   ├── cortex_ai.sql
│   ├── reset.sql
│   └── slides/
│
├── 04_governance/               # モジュール4
│   ├── README.md
│   ├── governance.sql
│   ├── reset.sql
│   └── slides/
│
├── 05_apps_collaboration/       # モジュール5
│   ├── README.md
│   ├── apps_collaboration.sql
│   ├── reset.sql
│   └── slides/
│
├── resources/                   # 追加リソース
│   ├── architecture.md
│   ├── faq.md
│   └── troubleshooting.md
│
└── utils/                       # ユーティリティ
    └── validation.sql
```

---

## 🏗️ アーキテクチャ

### データモデル概要

```
┌─────────────────────────────────────────────────────────────────┐
│                         TB_101 Database                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│  │   raw_pos    │   │ raw_customer │   │ raw_support  │        │
│  │              │   │              │   │              │        │
│  │ • country    │   │ • customer_  │   │ • truck_     │        │
│  │ • franchise  │   │   loyalty    │   │   reviews    │        │
│  │ • location   │   │              │   │              │        │
│  │ • menu       │   └──────────────┘   └──────────────┘        │
│  │ • truck      │                                               │
│  │ • order_     │          │                  │                 │
│  │   header     │          │                  │                 │
│  │ • order_     │          ▼                  ▼                 │
│  │   detail     │   ┌──────────────────────────────┐           │
│  └──────────────┘   │        harmonized            │           │
│         │           │                              │           │
│         │           │ • orders_v                   │           │
│         ▼           │ • customer_loyalty_metrics_v │           │
│  ┌──────────────┐   │ • truck_reviews_v            │           │
│  │  analytics   │   │ • daily_weather_v            │           │
│  │              │   └──────────────────────────────┘           │
│  │ • orders_v   │                                               │
│  │ • customer_  │                                               │
│  │   loyalty_   │   ┌──────────────┐   ┌──────────────┐        │
│  │   metrics_v  │   │  governance  │   │semantic_layer│        │
│  └──────────────┘   │              │   │              │        │
│                     │ • pii tag    │   │ • orders_v   │        │
│                     │ • policies   │   │ • customer_  │        │
│                     └──────────────┘   │   metrics_v  │        │
│                                        └──────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

### ロール階層

```
              ACCOUNTADMIN
                   │
              SECURITYADMIN ─────── SYSADMIN
                   │                    │
              USERADMIN            TB_ADMIN
                   │                    │
                   └───────┬────────────┘
                           │
                    TB_DATA_ENGINEER
                      │         │
               TB_DEV       TB_ANALYST
```

---

## 🔗 関連リソース

- [Snowflake Documentation](https://docs.snowflake.com/)
- [Snowflake Quickstarts](https://quickstarts.snowflake.com/)
- [Tasty Bytes - Data for All](https://quickstarts.snowflake.com/guide/tasty_bytes_introduction/)

---

## 📝 ライセンス

Copyright (c) 2025 Snowflake Inc. All rights reserved.

---

## 🤝 お問い合わせ

ご質問やフィードバックがございましたら、お気軽にお問い合わせください。
