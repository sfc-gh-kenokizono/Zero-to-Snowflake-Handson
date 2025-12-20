# Module 01: Snowflakeを始める

> 🎯 **目標**: Snowflakeの基本操作をマスターし、コスト管理まで体験する

---

## 📂 このモジュールで使用するファイル

| ファイル | 説明 | 使い方 |
|---------|------|--------|
| [`getting_started.sql`](./getting_started.sql) | **メインスクリプト** | Snowsightで開いて順番に実行 |
| [`reset.sql`](./reset.sql) | リセット用 | やり直したい時に実行 |
| `slides/01_getting_started.pdf` | 参考PDF | ※外部リンクあり、本READMEを推奨 |

> ⚠️ **注意**: PDFは参考資料です。手順はこのREADMEと`getting_started.sql`に従ってください。

---

## ⏱️ 所要時間

**約45分**（説明含む）

---

## 🎓 学習内容

```
┌─────────────────────────────────────────────────────────────────┐
│  1. ウェアハウス     → コンピュートリソースの作成・管理         │
│  2. クエリキャッシュ → 高速化とコスト削減の仕組み               │
│  3. ゼロコピークローン → 開発環境を一瞬で作成                   │
│  4. UNDROP          → 削除したテーブルを復元                    │
│  5. リソースモニター → クレジット使用量の監視                   │
│  6. 予算            → より柔軟なコスト管理                      │
│  7. ユニバーサル検索 → 自然言語でデータを探す                   │
└─────────────────────────────────────────────────────────────────┘
```

---

# 🔰 ハンズオン手順

## Step 0: 準備

### SQLファイルを開く

1. **Snowsight** にログイン
2. **Worksheets** → **+** → **SQL Worksheet**
3. [`getting_started.sql`](./getting_started.sql) の内容をコピー＆ペースト

### コンテキストを設定

```sql
-- getting_started.sql: 23-24行目
USE DATABASE tb_101;
USE ROLE accountadmin;
```

> 💡 `tb_101` は [00_setup](../00_setup/) で作成したデータベースです

---

## Step 1: ウェアハウスの作成と操作

📍 **SQLファイル**: [`getting_started.sql`](./getting_started.sql) の **61〜137行目**

### 1-1. 既存のウェアハウスを確認

```sql
SHOW WAREHOUSES;
```

### 1-2. 新しいウェアハウスを作成

```sql
CREATE OR REPLACE WAREHOUSE my_wh
    COMMENT = 'My TastyBytes warehouse'
    WAREHOUSE_TYPE = 'standard'
    WAREHOUSE_SIZE = 'xsmall'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2
    SCALING_POLICY = 'standard'
    AUTO_SUSPEND = 60
    INITIALLY_SUSPENDED = true
    AUTO_RESUME = false;
```

### 1-3. ウェアハウスを使用

```sql
USE WAREHOUSE my_wh;
```

### 1-4. クエリを実行（エラーになる！）

```sql
SELECT * FROM raw_pos.truck_details;
```

> ❌ **エラー**: ウェアハウスが一時停止中です

### 1-5. ウェアハウスを再開

```sql
ALTER WAREHOUSE my_wh RESUME;
ALTER WAREHOUSE my_wh SET AUTO_RESUME = TRUE;
```

### 1-6. 再度クエリを実行

```sql
SELECT * FROM raw_pos.truck_details;
```

> ✅ 今度は成功！

### 1-7. ウェアハウスをスケールアップ

```sql
ALTER WAREHOUSE my_wh SET warehouse_size = 'XLarge';
```

### 1-8. 大きなクエリを実行

```sql
SELECT
    o.truck_brand_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.price) AS total_sales
FROM analytics.orders_v o
GROUP BY o.truck_brand_name
ORDER BY total_sales DESC;
```

> 📊 **確認ポイント**: クエリ詳細パネルで実行時間を確認

---

## Step 2: クエリ結果キャッシュの体験

📍 **SQLファイル**: [`getting_started.sql`](./getting_started.sql) の **152〜179行目**

### 2-1. 同じクエリをもう一度実行

上記の「トラックごとの売上」クエリをもう一度実行してください。

> ⚡ **驚きポイント**: 2回目は **ミリ秒** で完了！

### なぜ速い？

```
┌──────────────────────────────────────────────────────┐
│  1回目: データベース → コンピュート → 結果（数秒）    │
│  2回目: キャッシュ → 結果（ミリ秒）                   │
└──────────────────────────────────────────────────────┘
```

- キャッシュは **24時間** 保持
- **ウェアハウス間で共有**
- コスト削減に効果的！

### 2-2. ウェアハウスを縮小

```sql
ALTER WAREHOUSE my_wh SET warehouse_size = 'XSmall';
```

---

## Step 3: ゼロコピークローン

📍 **SQLファイル**: [`getting_started.sql`](./getting_started.sql) の **181〜298行目**

### 3-1. テーブルをクローン

```sql
CREATE OR REPLACE TABLE raw_pos.truck_dev CLONE raw_pos.truck_details;
```

> 💡 **ポイント**: 追加ストレージ **ゼロ**、**即座** に完了！

### 3-2. クローンを確認

```sql
SELECT TOP 15 * FROM raw_pos.truck_dev ORDER BY truck_id;
```

### 3-3. 新しい列を追加

```sql
ALTER TABLE raw_pos.truck_dev ADD COLUMN IF NOT EXISTS year NUMBER;
ALTER TABLE raw_pos.truck_dev ADD COLUMN IF NOT EXISTS make VARCHAR(255);
ALTER TABLE raw_pos.truck_dev ADD COLUMN IF NOT EXISTS model VARCHAR(255);
```

### 3-4. VARIANTデータを展開

```sql
UPDATE raw_pos.truck_dev
SET 
    year = truck_build:year::NUMBER,
    make = truck_build:make::VARCHAR,
    model = truck_build:model::VARCHAR;
```

> 📝 **コロン演算子**: `truck_build:year` でVARIANTのキーにアクセス

### 3-5. データ品質を確認

```sql
SELECT make, COUNT(*) AS count
FROM raw_pos.truck_dev
GROUP BY make
ORDER BY make ASC;
```

> ⚠️ **問題発見**: 「Ford」と「Ford_」が別々にカウントされている！

### 3-6. データを修正

```sql
UPDATE raw_pos.truck_dev SET make = 'Ford' WHERE make = 'Ford_';
```

### 3-7. テーブルをスワップ（本番昇格）

```sql
ALTER TABLE raw_pos.truck_details SWAP WITH raw_pos.truck_dev; 
```

### 3-8. 古い列を削除

```sql
ALTER TABLE raw_pos.truck_details DROP COLUMN truck_build;
```

---

## Step 4: UNDROPでデータ復旧

📍 **SQLファイル**: [`getting_started.sql`](./getting_started.sql) の **299〜325行目**

### 4-1. 誤ってテーブルを削除（ドキドキ）

```sql
DROP TABLE raw_pos.truck_details;
```

### 4-2. テーブルが消えたことを確認

```sql
DESCRIBE TABLE raw_pos.truck_details;
```

> ❌ **エラー**: Table does not exist

### 4-3. UNDROPで復元（ホッ）

```sql
UNDROP TABLE raw_pos.truck_details;
```

### 4-4. 復元を確認

```sql
SELECT * FROM raw_pos.truck_details;
```

> ✅ **復活！** Time Travel機能により、24時間以内なら復元可能

### 4-5. 開発テーブルを削除

```sql
DROP TABLE raw_pos.truck_dev;
```

---

## Step 5: リソースモニター

📍 **SQLファイル**: [`getting_started.sql`](./getting_started.sql) の **327〜370行目**

### 5-1. リソースモニターを作成

```sql
USE ROLE accountadmin;

CREATE OR REPLACE RESOURCE MONITOR my_resource_monitor
    WITH CREDIT_QUOTA = 100
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS ON 75 PERCENT DO NOTIFY
             ON 90 PERCENT DO SUSPEND
             ON 100 PERCENT DO SUSPEND_IMMEDIATE;
```

### しきい値とアクション

| しきい値 | アクション | 説明 |
|---------|----------|------|
| 75% | NOTIFY | メール通知 |
| 90% | SUSPEND | 新規クエリを拒否（実行中は完了まで待機） |
| 100% | SUSPEND_IMMEDIATE | 即座に停止（実行中もキャンセル） |

### 5-2. ウェアハウスに適用

```sql
ALTER WAREHOUSE my_wh SET RESOURCE_MONITOR = my_resource_monitor;
```

---

## Step 6: 予算の設定

📍 **SQLファイル**: [`getting_started.sql`](./getting_started.sql) の **372〜432行目**

### 6-1. 予算を作成

```sql
CREATE OR REPLACE SNOWFLAKE.CORE.BUDGET my_budget()
    COMMENT = 'My Tasty Bytes Budget';
```

### 6-2. Snowsight UIで予算を設定

1. **Admin** → **Cost Management** → **Budgets**
2. **MY_BUDGET** をクリック
3. **編集** ボタンをクリック
4. 支出制限: `100`
5. メールアドレスを入力
6. **+ タグおよびリソース** で以下を追加:
   - `TB_101` → `ANALYTICS` スキーマ
   - `TB_DE_WH` ウェアハウス
7. **変更を保存**

---

## Step 7: ユニバーサル検索

📍 **SQLファイル**: [`getting_started.sql`](./getting_started.sql) の **434〜460行目**

### 7-1. 検索を体験

1. Snowsightの **検索** をクリック
2. 「`truck`」と入力
3. 結果を確認:
   - データベースオブジェクト
   - Marketplaceリスト
   - ドキュメント

### 7-2. 自然言語で検索

「Which truck franchise has the most loyal customer base?」

> 🔍 関連するテーブル・ビューが表示されます！

---

# 🎉 完了！

```sql
SELECT '🎉 Module 01 完了！次は Module 02: データパイプラインに進みましょう。' AS message;
```

---

## 🔄 リセット

やり直したい場合は [`reset.sql`](./reset.sql) を実行：

```sql
-- このモジュールで作成したオブジェクトを削除
DROP WAREHOUSE IF EXISTS my_wh;
DROP TABLE IF EXISTS raw_pos.truck_dev;
DROP RESOURCE MONITOR IF EXISTS my_resource_monitor;
```

---

## ➡️ 次のステップ

| 次のモジュール | 内容 |
|--------------|------|
| [02_data_pipelines](../02_data_pipelines/) | Dynamic Tablesでデータパイプラインを構築 |

---

## 📚 参考リンク（任意）

- [仮想ウェアハウスの概要](https://docs.snowflake.com/en/user-guide/warehouses-overview)
- [永続化されたクエリ結果](https://docs.snowflake.com/en/user-guide/querying-persisted-results)
- [リソースモニター](https://docs.snowflake.com/en/user-guide/resource-monitors)
- [予算](https://docs.snowflake.com/en/user-guide/budgets)
- [ユニバーサル検索](https://docs.snowflake.com/en/user-guide/ui-snowsight-universal-search)
