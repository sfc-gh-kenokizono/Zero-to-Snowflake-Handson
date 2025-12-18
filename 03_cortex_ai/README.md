# Module 03: Snowflake Cortex AI

Cortex AI SQL関数を使用して、顧客レビューデータから大規模なインサイトを抽出する方法を学びます。

---

## 📋 概要

**所要時間**: 約30分

### 学習目標

このモジュールを完了すると、以下ができるようになります：

- ✅ SENTIMENT()によるセンチメント分析
- ✅ AI_CLASSIFY()による自動分類
- ✅ EXTRACT_ANSWER()による回答抽出
- ✅ AI_SUMMARIZE_AGG()による要約生成
- ✅ 大規模データに対するAI分析の実行

---

## 📚 トピック

### 1. SENTIMENT() - センチメント分析

**目的**: テキストの感情を-1（ネガティブ）から+1（ポジティブ）でスコアリング

```sql
SELECT SNOWFLAKE.CORTEX.SENTIMENT(review) AS sentiment
FROM reviews;
```

**スコアの解釈**:
| スコア範囲 | 解釈 |
|-----------|------|
| 0.5 〜 1.0 | ポジティブ |
| -0.5 〜 0.5 | ニュートラル |
| -1.0 〜 -0.5 | ネガティブ |

### 2. AI_CLASSIFY() - 自動分類

**目的**: テキストをユーザー定義のカテゴリに分類

```sql
SELECT AI_CLASSIFY(
    review,
    ['Food Quality', 'Service', 'Price']
) AS category
FROM reviews;
```

**特徴**:
- キーワードマッチングではなくAIによる理解
- 任意のカテゴリを定義可能

### 3. EXTRACT_ANSWER() - 回答抽出

**目的**: テキストから特定の質問への回答を抽出

```sql
SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
    review,
    'What specific complaint is mentioned?'
) AS answer
FROM reviews;
```

**ユースケース**:
- 具体的なフィードバックの抽出
- 問題点の特定

### 4. AI_SUMMARIZE_AGG() - 集約要約

**目的**: 複数のテキストを1つの要約に集約

```sql
SELECT 
    category,
    AI_SUMMARIZE_AGG(review) AS summary
FROM reviews
GROUP BY category;
```

**特徴**:
- GROUP BY と組み合わせて使用
- エグゼクティブサマリーの生成に最適

---

## 🔧 ハンズオン手順

### Step 1: コンテキストの設定

```sql
USE ROLE tb_analyst;
USE DATABASE tb_101;
USE WAREHOUSE tb_analyst_wh;
```

### Step 2: 大規模センチメント分析

1. トラックブランドごとのレビューを分析
2. ポジティブ/ネガティブ/ニュートラルの分布を確認

### Step 3: 顧客フィードバックの分類

1. 食品品質、価格、サービス等のカテゴリを定義
2. AI_CLASSIFYで自動分類
3. ブランド別の分布を分析

### Step 4: 具体的なインサイトの抽出

1. EXTRACT_ANSWERで改善点・苦情を抽出
2. 都市別・ブランド別に整理

### Step 5: エグゼクティブサマリーの生成

1. AI_SUMMARIZE_AGGでブランド別要約を生成
2. 日本語翻訳（オプション）

---

## 📁 ファイル構成

| ファイル | 説明 |
|---------|------|
| `cortex_ai.sql` | メインSQLスクリプト |
| `reset.sql` | モジュールのリセットスクリプト |
| `slides/` | スライド資料 |

---

## 🧠 Cortex AI関数一覧

| 関数 | 用途 | 入力 | 出力 |
|-----|------|-----|------|
| `SENTIMENT()` | 感情分析 | テキスト | -1〜1のスコア |
| `AI_CLASSIFY()` | 分類 | テキスト, カテゴリ配列 | 分類結果 |
| `EXTRACT_ANSWER()` | 回答抽出 | テキスト, 質問 | 回答テキスト |
| `AI_SUMMARIZE_AGG()` | 集約要約 | テキスト群 | 要約テキスト |
| `AI_TRANSLATE()` | 翻訳 | テキスト, 言語 | 翻訳テキスト |
| `COMPLETE()` | テキスト生成 | プロンプト | 生成テキスト |

---

## ⚠️ 注意事項

### 処理時間

- AI関数は通常のSQLより処理時間がかかります
- 大量データの場合はLIMITで制限してテスト

### リージョン制限

- 一部のモデルはリージョンによって利用不可
- クロスリージョン設定で解決可能

```sql
-- クロスリージョン有効化（セットアップ済み）
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';
```

### コスト

- AI関数はコンピュートクレジットを消費
- 本番環境では使用量を監視

---

## 🔄 リセット

このモジュールで作成したオブジェクトをクリーンアップする場合：

```sql
-- reset.sql を実行
```

（このモジュールは主にSELECTクエリのため、リセット対象は最小限です）

---

## ✅ 確認問題

1. SENTIMENTスコアが0.3の場合、どのような感情を示していますか？

2. AI_CLASSIFYとキーワードマッチングの違いは何ですか？

3. AI_SUMMARIZE_AGGはどのような場面で有効ですか？

---

## 📖 参考リンク

- [Cortex AI Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- [SENTIMENT Function](https://docs.snowflake.com/en/sql-reference/functions/sentiment-snowflake-cortex)
- [AI_CLASSIFY Function](https://docs.snowflake.com/en/sql-reference/functions/ai_classify)
- [EXTRACT_ANSWER Function](https://docs.snowflake.com/en/sql-reference/functions/extract_answer-snowflake-cortex)

---

## ➡️ 次のステップ

[Module 04: ガバナンス](../04_governance/) に進んでください。

