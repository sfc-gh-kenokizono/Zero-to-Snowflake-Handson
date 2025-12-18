# Module 00: 環境セットアップ

このモジュールでは、ハンズオンに必要なSnowflake環境を構築します。

---

## 📋 概要

**所要時間**: 約15分（データロード含む）

### 作成されるオブジェクト

| カテゴリ | オブジェクト |
|---------|------------|
| データベース | `TB_101` |
| スキーマ | `raw_pos`, `raw_customer`, `raw_support`, `harmonized`, `analytics`, `governance`, `semantic_layer` |
| ウェアハウス | `tb_de_wh`, `tb_dev_wh`, `tb_analyst_wh`, `tb_cortex_wh` |
| ロール | `tb_admin`, `tb_data_engineer`, `tb_dev`, `tb_analyst` |

---

## 🚀 セットアップ手順

### Step 1: Snowsightにログイン

1. [app.snowflake.com](https://app.snowflake.com) にアクセス
2. 認証情報を入力してログイン

### Step 2: ワークシートを作成

1. 左メニューから「**Worksheets**」をクリック
2. 右上の「**+**」ボタンをクリック
3. 「**SQL Worksheet**」を選択

### Step 3: ロールを確認

ワークシート右上のコンテキストメニューで以下を確認：
- **Role**: `ACCOUNTADMIN` または `SYSADMIN`

### Step 4: セットアップSQLを実行

1. `setup.sql` の内容をワークシートにコピー
2. 全体を選択（Cmd+A / Ctrl+A）
3. 実行ボタン（▶）をクリック、または Cmd+Enter / Ctrl+Enter

### Step 5: 完了確認

以下のクエリで環境が正しくセットアップされたことを確認：

```sql
-- データベース確認
SHOW DATABASES LIKE 'TB_101';

-- テーブル確認（注文ヘッダーに約6,200万行）
SELECT COUNT(*) FROM tb_101.raw_pos.order_header;

-- ロール確認
SHOW ROLES LIKE 'TB_%';
```

---

## 📁 ファイル構成

| ファイル | 説明 |
|---------|------|
| `setup.sql` | 環境構築SQL（データベース、スキーマ、テーブル、データロード） |
| `cleanup.sql` | 環境の完全削除SQL |

---

## ⚠️ 注意事項

### データロード時間について

- S3からのデータロードには **5-10分** かかることがあります
- `order_detail` テーブルのロードが最も時間がかかります
- ロード中は別の作業を進めないでください

### トライアルアカウントの場合

- トライアルアカウントでも全機能を利用可能です
- クレジット残量に注意してください（セットアップで約2-3クレジット消費）

### エラーが発生した場合

1. **「Insufficient privileges」エラー**
   - `ACCOUNTADMIN` ロールに切り替えてください

2. **「Object already exists」エラー**
   - 以前のセットアップが残っています
   - `cleanup.sql` を実行してから再度セットアップしてください

3. **データロードが失敗する場合**
   - ネットワーク接続を確認
   - ウェアハウスが起動しているか確認

---

## 🔄 クリーンアップ

ハンズオン終了後、または環境をリセットしたい場合：

```sql
-- cleanup.sql を実行
-- ⚠️ すべてのデータが削除されます
```

---

## 📊 データモデル

### Tasty Bytes データセット

架空のフードトラック企業「Tasty Bytes」のデータを使用します：

- **国・都市**: 15カ国、30都市以上
- **フードトラック**: 450台以上
- **メニュー**: 15ブランド、100アイテム以上
- **注文データ**: 約6,200万件（2019-2022年）
- **顧客**: ロイヤルティプログラム会員データ
- **レビュー**: 顧客レビューデータ

---

## ✅ チェックリスト

セットアップ完了後、以下を確認してください：

- [ ] `TB_101` データベースが存在する
- [ ] `raw_pos.order_header` に約6,200万行のデータがある
- [ ] `tb_admin`, `tb_data_engineer`, `tb_dev`, `tb_analyst` ロールが存在する
- [ ] `tb_de_wh`, `tb_dev_wh`, `tb_analyst_wh`, `tb_cortex_wh` ウェアハウスが存在する

すべてのチェックが完了したら、次のモジュール [01_getting_started](../01_getting_started/) に進んでください。

