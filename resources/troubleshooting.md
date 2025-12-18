# トラブルシューティングガイド

ハンズオン中に発生する可能性のある問題と解決方法をまとめています。

---

## 🔴 一般的なエラー

### Error: "Object does not exist or not authorized"

**原因**: 
- オブジェクトが存在しない
- 現在のロールに権限がない

**解決方法**:
```sql
-- 1. オブジェクトの存在確認
SHOW TABLES LIKE '%table_name%';
SHOW VIEWS LIKE '%view_name%';

-- 2. 現在のロール確認
SELECT CURRENT_ROLE();

-- 3. 適切なロールに切り替え
USE ROLE accountadmin;  -- または適切なロール

-- 4. 権限の確認
SHOW GRANTS ON TABLE schema.table_name;
```

---

### Error: "Warehouse is not running"

**原因**: ウェアハウスが一時停止中

**解決方法**:
```sql
-- ウェアハウスを再開
ALTER WAREHOUSE tb_de_wh RESUME;

-- または AUTO_RESUME を有効化
ALTER WAREHOUSE tb_de_wh SET AUTO_RESUME = TRUE;
```

---

### Error: "SQL compilation error"

**原因**: SQL構文エラーまたは参照エラー

**解決方法**:
1. 構文を確認（カンマ、括弧の閉じ忘れなど）
2. オブジェクト名のスペルを確認
3. データベース/スキーマのコンテキストを確認

```sql
-- コンテキスト確認
SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();

-- コンテキスト設定
USE DATABASE tb_101;
USE SCHEMA raw_pos;
```

---

### Error: "Insufficient privileges"

**原因**: 現在のロールに必要な権限がない

**解決方法**:
```sql
-- 1. 必要な権限を持つロールに切り替え
USE ROLE accountadmin;

-- 2. 権限を付与（管理者として）
GRANT SELECT ON TABLE schema.table TO ROLE target_role;
GRANT USAGE ON WAREHOUSE wh_name TO ROLE target_role;
```

---

## 🟡 モジュール別の問題

### Module 00: セットアップ

#### データロードが失敗する

**確認事項**:
- ネットワーク接続
- ウェアハウスのサイズ（Largeを推奨）
- S3へのアクセス

```sql
-- ステージの確認
LIST @tb_101.public.s3load;

-- 手動でロード再試行
COPY INTO tb_101.raw_pos.order_header
FROM @tb_101.public.s3load/raw_pos/order_header/
ON_ERROR = 'CONTINUE';
```

---

### Module 01: Snowflakeを始める

#### リソースモニターが作成できない

**確認事項**:
- `ACCOUNTADMIN`ロールを使用しているか

```sql
USE ROLE accountadmin;
CREATE RESOURCE MONITOR my_monitor WITH CREDIT_QUOTA = 100;
```

#### 予算が表示されない

**確認事項**:
- メールアドレスが確認済みか
- `ACCOUNTADMIN`ロールでアクセスしているか

---

### Module 02: データパイプライン

#### Dynamic Tableが作成できない

**確認事項**:
- ウェアハウスが指定されているか
- ソーステーブルが存在するか

```sql
-- ソースデータの確認
SELECT COUNT(*) FROM raw_pos.menu_staging;

-- Dynamic Table作成（ウェアハウス明示）
CREATE DYNAMIC TABLE my_dt
    LAG = '1 minute'
    WAREHOUSE = 'TB_DE_WH'
AS SELECT ...;
```

#### Dynamic Tableが更新されない

**解決方法**:
```sql
-- 状態確認
DESCRIBE DYNAMIC TABLE harmonized.ingredient;

-- 手動リフレッシュ
ALTER DYNAMIC TABLE harmonized.ingredient REFRESH;
```

---

### Module 03: Cortex AI

#### Cortex関数がタイムアウトする

**解決方法**:
1. データ量を減らす（LIMITを使用）
2. ウェアハウスサイズを大きくする

```sql
-- データ量を制限
SELECT SNOWFLAKE.CORTEX.SENTIMENT(review)
FROM table
LIMIT 100;
```

#### AI_TRANSLATEで言語エラー

**確認事項**:
- 言語コードが正しいか（'en', 'ja' など）
- サポートされている言語か

```sql
-- 正しい形式
SNOWFLAKE.CORTEX.AI_TRANSLATE(text, 'en', 'ja')
```

---

### Module 04: ガバナンス

#### 分類プロファイルが作成できない

**確認事項**:
- 必要な権限があるか

```sql
-- 権限付与
GRANT CREATE SNOWFLAKE.DATA_PRIVACY.CLASSIFICATION_PROFILE 
ON SCHEMA governance TO ROLE my_role;
```

#### マスキングが機能しない

**確認事項**:
1. タグが列に設定されているか
2. マスキングポリシーがタグに関連付けられているか
3. テスト用のロールで実行しているか

```sql
-- タグ確認
SELECT * FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
    'raw_customer.customer_loyalty', 'table'));

-- 異なるロールでテスト
USE ROLE public;
SELECT * FROM raw_customer.customer_loyalty LIMIT 10;
```

---

### Module 05: アプリとコラボレーション

#### Marketplaceデータが見つからない

**確認事項**:
- `ACCOUNTADMIN`ロールを使用
- 正確な検索キーワード

**解決方法**:
1. Snowsightで`ACCOUNTADMIN`に切り替え
2. Marketplaceで「Weather Source frostbyte」を検索
3. 正確なリスト名を選択

#### 取得したデータにクエリできない

**確認事項**:
- データベース名が正しいか
- 権限が付与されているか

```sql
-- データベース確認
SHOW DATABASES LIKE 'ZTS%';

-- 権限付与
GRANT IMPORTED PRIVILEGES ON DATABASE zts_weathersource TO ROLE public;
```

---

## 🟢 パフォーマンス改善

### クエリが遅い場合

1. **ウェアハウスサイズを上げる**
   ```sql
   ALTER WAREHOUSE my_wh SET WAREHOUSE_SIZE = 'LARGE';
   ```

2. **クエリプロファイルを確認**
   - Snowsightでクエリ履歴を開く
   - 「Profile」タブで実行計画を確認

3. **クラスタリングキーを検討**
   ```sql
   ALTER TABLE my_table CLUSTER BY (date_column);
   ```

---

## 📋 診断クエリ

問題調査に役立つクエリ集：

```sql
-- 現在のセッション情報
SELECT 
    CURRENT_USER(),
    CURRENT_ROLE(),
    CURRENT_DATABASE(),
    CURRENT_SCHEMA(),
    CURRENT_WAREHOUSE();

-- ウェアハウス状態
SHOW WAREHOUSES;

-- 最近のクエリ履歴
SELECT query_id, query_text, error_message, execution_status
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
ORDER BY start_time DESC
LIMIT 10;

-- ロールの権限確認
SHOW GRANTS TO ROLE my_role;

-- オブジェクトの権限確認
SHOW GRANTS ON TABLE schema.table;
```

---

## 📞 サポート

解決しない場合は：

1. **エラーメッセージを記録**
2. **クエリIDを控える**
3. **実行環境を確認**（ロール、ウェアハウス、データベース）

サポート連絡先：
- Snowflake Support: support.snowflake.com
- Snowflake Community: community.snowflake.com

