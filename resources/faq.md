# よくある質問（FAQ）

Zero to Snowflake ハンズオンに関するよくある質問と回答です。

---

## 🔧 セットアップ関連

### Q: セットアップSQLの実行中にエラーが発生します

**A:** 以下を確認してください：

1. **ロールの確認**: `ACCOUNTADMIN`または`SYSADMIN`で実行していますか？
   - Workspacesの右上コンテキストパネルで確認
   ```sql
   SELECT CURRENT_ROLE();
   ```

2. **既存オブジェクトの確認**: 以前のセットアップが残っている可能性があります
   ```sql
   -- cleanup.sqlを実行してから再度セットアップ
   ```

3. **ウェアハウスの確認**: ウェアハウスが選択されていますか？
   - Workspacesの右上コンテキストパネルで確認

### Q: データロードに時間がかかります

**A:** `order_detail`テーブルのロードには10-15分かかることがあります。これは正常な動作です。

### Q: トライアルアカウントでも実行できますか？

**A:** はい、すべての機能を利用可能です。ただし、以下に注意してください：
- クレジット残量を監視してください
- セットアップで約2-3クレジット消費します
- 全モジュール完了で約5-10クレジット消費の見込み

---

## 💻 ウェアハウス関連

### Q: ウェアハウスが起動しません

**A:** 以下を確認してください：

```sql
-- ウェアハウスの状態を確認
SHOW WAREHOUSES LIKE 'TB_%';

-- 手動で再開
ALTER WAREHOUSE tb_de_wh RESUME;
```

### Q: クエリが遅いです

**A:** ウェアハウスサイズを一時的に大きくしてください：

```sql
ALTER WAREHOUSE tb_de_wh SET WAREHOUSE_SIZE = 'LARGE';

-- クエリ実行後、元に戻す
ALTER WAREHOUSE tb_de_wh SET WAREHOUSE_SIZE = 'XSMALL';
```

---

## 🔐 権限・ロール関連

### Q: 「Insufficient privileges」エラーが出ます

**A:** 現在のロールを確認し、適切なロールに切り替えてください：

```sql
-- 現在のロール確認
SELECT CURRENT_ROLE();

-- ロール切り替え例
USE ROLE accountadmin;
-- または
USE ROLE tb_data_engineer;
```

### Q: 作成したロールが表示されません

**A:** ロールを自分自身に付与する必要があります：

```sql
GRANT ROLE my_role TO USER <your_username>;
```

> 💡 Workspacesのコンテキストパネルでロールを変更すると、付与されていないロールは表示されません

---

## 🤖 Cortex AI関連

### Q: Cortex関数がエラーになります

**A:** 以下を確認してください：

1. **リージョンの確認**: 一部のモデルはリージョン制限があります

2. **クロスリージョン設定**:
   ```sql
   -- セットアップで既に設定済み
   ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';
   ```

3. **権限の確認**:
   ```sql
   GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE <your_role>;
   ```

### Q: SENTIMENT関数の結果が NULL です

**A:** 入力テキストが空または NULL の可能性があります：

```sql
SELECT review, SNOWFLAKE.CORTEX.SENTIMENT(review)
FROM table
WHERE review IS NOT NULL AND LENGTH(review) > 0;
```

---

## 📊 Dynamic Tables関連

### Q: Dynamic Tableが更新されません

**A:** LAG設定の時間を待つ必要があります：

```sql
-- Dynamic Tableの状態を確認
SHOW DYNAMIC TABLES;

-- 手動で更新をトリガー
ALTER DYNAMIC TABLE my_dt REFRESH;
```

### Q: DAGが表示されません

**A:** Snowsightのカタログから確認してください：

1. 左メニュー「Data」→「Databases」をクリック
2. データベース → スキーマ → ダイナミックテーブルを展開
3. テーブルを選択し「Graph」タブをクリック

> 💡 WorkspacesからもDatabase Explorerパネルでアクセス可能です

---

## 🔒 ガバナンス関連

### Q: マスキングポリシーが適用されません

**A:** 以下を確認してください：

1. タグがテーブル列に正しく設定されているか
2. マスキングポリシーがタグに関連付けられているか
3. 現在のロールがポリシーの対象か

```sql
-- タグの確認
SELECT * FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('schema.table', 'table'));
```

### Q: 行アクセスポリシー後にデータが見えません

**A:** ポリシーマップにロールが登録されているか確認：

```sql
SELECT * FROM governance.row_policy_map;
```

---

## 🌐 Marketplace関連

### Q: Marketplaceリストが見つかりません

**A:** 以下を確認してください：

1. `ACCOUNTADMIN`ロールを使用している
2. 検索キーワードが正確（「Weather Source frostbyte」）
3. リージョンによって利用可能なリストが異なる場合があります

### Q: 取得したデータにアクセスできません

**A:** 取得時に権限を付与しましたか？

```sql
-- PUBLICに権限を付与
GRANT IMPORTED PRIVILEGES ON DATABASE zts_weathersource TO ROLE PUBLIC;
```

---

## 📝 その他

### Q: クエリタグとは何ですか？

**A:** クエリの追跡・分類に使用するメタデータです。ハンズオンでは進捗追跡に使用しています。

```sql
-- クエリタグの確認
SELECT CURRENT_SESSION():query_tag;

-- クエリタグの解除
ALTER SESSION UNSET query_tag;
```

### Q: ハンズオン後に環境をクリーンアップしたい

**A:** `00_setup/cleanup.sql`を実行してください：

```sql
-- 完全クリーンアップ
-- ⚠️ すべてのデータが削除されます
```

---

## 📞 さらにヘルプが必要な場合

- [Snowflake Documentation](https://docs.snowflake.com/)
- [Snowflake Community](https://community.snowflake.com/)
- [Snowflake Support](https://support.snowflake.com/)

