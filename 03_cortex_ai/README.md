# Module 03: Cortex AI SQL関数

> 🎯 **目標**: SQLだけでAI分析を体験する - センチメント分析から要約まで

---

## 📂 このモジュールで使用するファイル

| ファイル | 説明 | 使い方 |
|---------|------|--------|
| [`03_cortex_ai.sql`](./03_cortex_ai.sql) | **メインスクリプト** | Snowsightで開いて順番に実行 |
| [`03_reset.sql`](./03_reset.sql) | リセット用 | やり直したい時に実行 |

---

## ⏱️ 所要時間

**約30分**（説明含む）

---

## 🎓 学習内容

| # | 関数 | 内容 |
|---|------|------|
| 1 | `SENTIMENT()` | レビューの感情を数値化 |
| 2 | `AI_CLASSIFY()` | テーマ別に自動分類 |
| 3 | `EXTRACT_ANSWER()` | 具体的な苦情・賞賛を抽出 |
| 4 | `AI_SUMMARIZE_AGG()` | ブランド別に要約を生成 |

---

## ✨ Cortex AI SQL関数とは？

> **「SQLを書くだけでAI分析ができる」**

- ✅ 機械学習の知識不要
- ✅ モデルのデプロイ不要
- ✅ データを外部に出さない（セキュア）
- ✅ 大規模データに対応

---

# 🔰 ハンズオン手順

## Step 0: 準備

### SQLファイルを準備

1. **Snowsight** にログイン
2. GitHubで [`03_cortex_ai.sql`](./03_cortex_ai.sql) を開き、**Raw** → 全文コピー
3. **Projects** → **Worksheets** → **+** で新規ワークシートを作成
4. コピーした内容をペースト

### コンテキストを設定

画面右上のコンテキストパネルで以下を設定：
- **Role**: `TB_ANALYST`
- **Database**: `TB_101`
- **Warehouse**: `TB_ANALYST_WH`

```sql
-- 03_cortex_ai.sql: 22-24行目
USE ROLE tb_analyst;
USE DATABASE tb_101;
USE WAREHOUSE tb_analyst_wh;
```

> 💡 今回は **アナリスト** ロールを使用します

---

## Step 1: SENTIMENT() - センチメント分析

📍 **SQLファイル**: [`03_cortex_ai.sql`](./03_cortex_ai.sql) の **27〜105行目**

### ビジネス上の質問

> 「各トラックブランドに対して顧客はどのように感じているか？」

### 1-1. センチメント分析を実行

```sql
SELECT
    truck_brand_name,
    COUNT(*) AS total_reviews,
    AVG(CASE WHEN sentiment >= 0.5 THEN sentiment END) AS avg_positive_score,
    AVG(CASE WHEN sentiment BETWEEN -0.5 AND 0.5 THEN sentiment END) AS avg_neutral_score,
    AVG(CASE WHEN sentiment <= -0.5 THEN sentiment END) AS avg_negative_score
FROM (
    SELECT
        truck_brand_name,
        SNOWFLAKE.CORTEX.SENTIMENT(review) AS sentiment
    FROM harmonized.truck_reviews_v
    WHERE language ILIKE '%en%' AND review IS NOT NULL
    LIMIT 1000
)
GROUP BY truck_brand_name
ORDER BY total_reviews DESC;
```

### センチメントスコアの範囲

| スコア | 意味 |
|-------|------|
| **0.5 〜 1.0** | ポジティブ 😊 |
| **-0.5 〜 0.5** | ニュートラル 😐 |
| **-1.0 〜 -0.5** | ネガティブ 😞 |

> 💡 **ポイント**: 1件ずつではなく、**1,000件**を一括分析！

---

## Step 2: AI_CLASSIFY() - 自動分類

📍 **SQLファイル**: [`03_cortex_ai.sql`](./03_cortex_ai.sql) の **107〜156行目**

### ビジネス上の質問

> 「顧客は主に何についてコメントしているか？」

### 2-1. 具体的なカテゴリでラベル分類

```sql
SELECT
    truck_brand_name,
    LEFT(review, 80) || '...' AS review_preview,
    AI_CLASSIFY(
        review,
        ['Food Quality', 'Wait Time', 'Price', 'Portion Size']
    ):labels[0]::STRING AS category
FROM harmonized.truck_reviews_v
WHERE language = 'en' AND review IS NOT NULL
LIMIT 50;
```

### 2-2. カテゴリを変えて試す

```sql
SELECT
    truck_brand_name,
    LEFT(review, 80) || '...' AS review_preview,
    AI_CLASSIFY(
        review,
        ['Taste', 'Freshness', 'Staff Friendliness', 'Value for Money']
    ):labels[0]::STRING AS category
FROM harmonized.truck_reviews_v
WHERE language = 'en' AND review IS NOT NULL
LIMIT 50;
```

### AI_CLASSIFY() の仕組み

| | 内容 |
|---|------|
| **入力（レビュー）** | "The tacos were amazing but I waited 20 minutes" |
| **入力（カテゴリ）** | `['Food Quality', 'Wait Time', 'Price']` |
| **出力** | `'Food Quality'`（最も該当するカテゴリ） |

> 💡 **ポイント**: カテゴリの定義次第で、同じレビューでも異なる視点から分類できます

---

## Step 3: EXTRACT_ANSWER() - 回答抽出

📍 **SQLファイル**: [`03_cortex_ai.sql`](./03_cortex_ai.sql) の **158〜219行目**

### ビジネス上の質問

> 「具体的にどんな苦情・賞賛があるか？」

### 3-1. 具体的なフィードバックを抽出

```sql
SELECT
    truck_brand_name,
    primary_city,
    LEFT(review, 100) || '...' AS review_preview,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        review,
        'What specific improvement or complaint is mentioned in this review?'
    ) AS specific_feedback
FROM harmonized.truck_reviews_v
WHERE language = 'en' AND review IS NOT NULL AND LENGTH(review) > 50
ORDER BY truck_brand_name, primary_city ASC
LIMIT 20;
```

### EXTRACT_ANSWER() の仕組み

| | 内容 |
|---|------|
| **入力（レビュー）** | "I waited 30 minutes for my order but the friendly staff was saving grace..." |
| **入力（質問）** | "What complaint is mentioned?" |
| **出力** | "waited 30 minutes for order" |

> 💡 **ポイント**: 長文から**具体的なアクションアイテム**を抽出

---

## Step 4: AI_SUMMARIZE_AGG() - 要約生成

📍 **SQLファイル**: [`03_cortex_ai.sql`](./03_cortex_ai.sql) の **221〜295行目**

### ビジネス上の質問

> 「各トラックブランドの全体的な評価はどうか？」

### 4-1. ブランド別の要約を生成

```sql
SELECT
  truck_brand_name,
  AI_SUMMARIZE_AGG(review) AS review_summary,
  SNOWFLAKE.CORTEX.AI_TRANSLATE(review_summary, 'en', 'ja') AS review_summary_ja
FROM (
    SELECT truck_brand_name, review
    FROM harmonized.truck_reviews_v
    LIMIT 100
)
GROUP BY truck_brand_name;
```

### AI_SUMMARIZE_AGG() の仕組み

| | 内容 |
|---|------|
| **入力** | 100件のレビュー |
| **出力（英語）** | "Customers praise the fresh ingredients and fast service. Common complaints include long wait times during peak hours and limited menu options..." |
| **出力（日本語訳）** | 「顧客は新鮮な食材と迅速なサービスを称賛しています。一般的な不満には、ピーク時の長い待ち時間と限られたメニューオプションが含まれます...」 |

> 💡 **ポイント**: エグゼクティブ向けの**簡潔なサマリー**を自動生成

---

## 🔥 おまけ: AI_TRANSLATE() - 翻訳

上記の例で使用している `AI_TRANSLATE()` も便利な関数です：

```sql
SNOWFLAKE.CORTEX.AI_TRANSLATE(text, 'en', 'ja')
```

| パラメータ | 説明 |
|-----------|------|
| 第1引数 | 翻訳するテキスト |
| 第2引数 | 元の言語（'en' = 英語） |
| 第3引数 | 翻訳先言語（'ja' = 日本語） |

---

# 🎉 完了！

```sql
SELECT '🎉 Module 03 完了！次は Module 04: ガバナンスに進みましょう。' AS message;
```

---

## 📊 まとめ: 使用した関数

| 関数 | 用途 | ビジネス価値 |
|------|------|-------------|
| `SENTIMENT()` | 感情分析 | 顧客満足度の定量化 |
| `AI_CLASSIFY()` | 自動分類 | フィードバックのカテゴリ分け |
| `EXTRACT_ANSWER()` | 回答抽出 | 具体的なアクションアイテム特定 |
| `AI_SUMMARIZE_AGG()` | 要約生成 | エグゼクティブサマリー |
| `AI_TRANSLATE()` | 翻訳 | 多言語対応 |

---

## 🔄 リセット

やり直したい場合は [`03_reset.sql`](./03_reset.sql) を実行してください。

---

## ➡️ 次のステップ

| 次のモジュール | 内容 |
|--------------|------|
| [04_governance](../04_governance/) | Horizonによるガバナンス（RBAC、マスキング、行アクセス） |

---

## 📚 参考リンク（任意）

- [Cortex AI SQL関数](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-ai-sql-functions)
- [SENTIMENT関数](https://docs.snowflake.com/en/sql-reference/functions/sentiment-snowflake-cortex)
- [AI_CLASSIFY関数](https://docs.snowflake.com/en/sql-reference/functions/ai_classify-snowflake-cortex)
- [EXTRACT_ANSWER関数](https://docs.snowflake.com/en/sql-reference/functions/extract_answer-snowflake-cortex)
- [AI_SUMMARIZE_AGG関数](https://docs.snowflake.com/en/sql-reference/functions/ai_summarize_agg-snowflake-cortex)
