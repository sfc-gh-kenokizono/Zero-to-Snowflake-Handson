/*************************************************************************************************** 
Zero to Snowflake ハンズオン - Cortex AI SQL関数
Version: v2     
Copyright(c): 2025 Snowflake Inc. All rights reserved.
****************************************************************************************************

このモジュールで学ぶこと:
1. SENTIMENT()を使用してトラック顧客レビューをポジティブ、ネガティブ、またはニュートラルとしてスコアリングおよびラベル付け
2. AI_CLASSIFY()を使用して、食品の品質やサービス体験などのテーマごとにレビューを分類
3. EXTRACT_ANSWER()を使用してレビューテキストから特定の苦情や賞賛を抽出
4. AI_SUMMARIZE_AGG()を使用してトラックブランド名ごとの顧客センチメントの要約を生成

****************************************************************************************************/

ALTER SESSION SET query_tag = '{"origin":"sf_sit-is","name":"tb_zts","version":{"major":1, "minor":1},"attributes":{"is_quickstart":1, "source":"tastybytes", "vignette": "aisql_functions"}}';

/*
    AISQL関数を活用して顧客レビューからインサイトを得る意図でTastyBytesデータアナリストの
    役割を担うので、コンテキストを適切に設定しましょう。
    💡 Workspacesの場合、画面右上のコンテキストパネルからも設定可能です
*/

USE ROLE tb_analyst;
USE DATABASE tb_101;
USE WAREHOUSE tb_analyst_wh;

/*===================================================================================
  1. 大規模なセンチメント分析
  ===================================================================================
   すべてのフードトラックブランドの顧客センチメントを分析して、最もパフォーマンスの高い
   トラックを特定し、フリート全体の顧客満足度メトリクスを作成します。
   
   SENTIMENT()関数を使用して、顧客レビューを-1（ネガティブ）から+1（ポジティブ）まで
   自動的にスコアリングします。
-----------------------------------------------------------------------------------*/

-- ビジネス上の質問: 「各トラックブランドに対して顧客はどのように感じているか？」

-- ============================================
-- Step 1: まず、分析対象のデータを確認しましょう
-- ============================================
-- truck_reviews_v にどんなレビューが入っているか見てみます

SELECT 
    truck_brand_name,
    primary_city,
    review,
    language
FROM harmonized.truck_reviews_v
WHERE language = 'en' 
  AND review IS NOT NULL
LIMIT 10;

-- ============================================
-- Step 2: 10件のレビューにSENTIMENT関数を適用
-- ============================================
-- SENTIMENT()関数がどのようにスコアを返すか確認します
-- スコアは -1（ネガティブ）〜 +1（ポジティブ）の範囲です

SELECT 
    truck_brand_name,
    LEFT(review, 80) || '...' AS review_preview,
    SNOWFLAKE.CORTEX.SENTIMENT(review) AS sentiment_score
FROM harmonized.truck_reviews_v
WHERE language = 'en' 
  AND review IS NOT NULL
LIMIT 10;

-- 💡 ポイント: スコアを見て、ポジティブ/ネガティブな内容と一致しているか確認してください

-- ============================================
-- Step 3: ブランド別にセンチメントを集計
-- ============================================
-- 1,000件のレビューを一括分析し、ブランドごとの顧客満足度を比較します

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
    WHERE
        language ILIKE '%en%'
        AND review IS NOT NULL
    LIMIT 1000
)
GROUP BY
    truck_brand_name
ORDER BY total_reviews DESC;

/*
    💡 ポイント:
        SENTIMENT()関数は、すべてのレビューを自動的にスコアリングし、
        ポジティブ、ネガティブ、ニュートラルに分類します。
        
    センチメントスコアの範囲:
        ポジティブ:   0.5 ～ 1
        ニュートラル: -0.5 ～ 0.5
        ネガティブ:   -0.5 ～ -1
*/

/*===================================================================================
  2. 顧客フィードバックの分類
  ===================================================================================
   AI_CLASSIFY()関数は、テキストを指定したカテゴリに自動分類します。
   キーワードマッチングではなく、AIが意味を理解して分類するのがポイントです。
-----------------------------------------------------------------------------------*/

-- ビジネス上の質問: 「顧客は主に何についてコメントしているか？」

-- ============================================
-- Step 1: 具体的なカテゴリでラベル分類
-- ============================================
-- レビューを具体的なカテゴリに分類します

SELECT
    truck_brand_name,
    LEFT(review, 80) || '...' AS review_preview,
    AI_CLASSIFY(
        review,
        ['Food Quality', 'Wait Time', 'Price', 'Portion Size']
    ):labels[0]::STRING AS category
FROM harmonized.truck_reviews_v
WHERE language = 'en' 
  AND review IS NOT NULL
  AND LENGTH(review) > 30
LIMIT 50;

-- 💡 ポイント: 
--    - AIがレビュー内容を理解し、最も適切なカテゴリに分類します
--    - 具体的なカテゴリを指定すると、より多様な分類結果が得られます

-- ============================================
-- Step 2: カテゴリを変えて試してみる
-- ============================================
-- 別のカテゴリセットで分類してみましょう

SELECT
    truck_brand_name,
    LEFT(review, 80) || '...' AS review_preview,
    AI_CLASSIFY(
        review,
        ['Taste', 'Freshness', 'Staff Friendliness', 'Value for Money']
    ):labels[0]::STRING AS category
FROM harmonized.truck_reviews_v
WHERE language = 'en' 
  AND review IS NOT NULL
  AND LENGTH(review) > 30
LIMIT 50;

-- 💡 ポイント: カテゴリの定義次第で、同じレビューでも異なる視点から分類できます

/*===================================================================================
  3. 特定の運用インサイトの抽出
  ===================================================================================
   EXTRACT_ANSWER()関数を使用して、非構造化テキストから正確な回答を抽出します。
   顧客フィードバックに関する特定のビジネス上の質問をして、直接的な回答を受け取れます。
-----------------------------------------------------------------------------------*/

-- ビジネス上の質問: 「各顧客レビュー内で見つかる具体的な苦情や賞賛は何か？」

-- ============================================
-- Step 1: EXTRACT_ANSWER関数の動作を確認
-- ============================================
-- まず3件のレビューで、どのように回答が抽出されるか見てみます

SELECT
    truck_brand_name,
    review,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        review,
        'What specific improvement or complaint is mentioned in this review?'
    ) AS extracted_answer
FROM harmonized.truck_reviews_v
WHERE language = 'en'
  AND review IS NOT NULL
  AND LENGTH(review) > 50
LIMIT 3;

-- 💡 ポイント: answer キーに抽出された回答が、score キーに信頼度が返されます

-- ============================================
-- Step 2: 複数のレビューから具体的なフィードバックを抽出
-- ============================================
-- レビュー本文の一部と、抽出された回答を並べて確認します

SELECT
    truck_brand_name,
    primary_city,
    LEFT(review, 100) || '...' AS review_preview,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        review,
        'What specific improvement or complaint is mentioned in this review?'
    ) AS specific_feedback
FROM 
    harmonized.truck_reviews_v
WHERE 
    language = 'en'
    AND review IS NOT NULL
    AND LENGTH(review) > 50
ORDER BY truck_brand_name, primary_city ASC
LIMIT 20;

-- 💡 ポイント: 長いレビューから「親切なスタッフが救いだった」「待ち時間が長かった」など
--    具体的なフィードバックが自動的に抽出されています

/*
    重要なインサイト:
        EXTRACT_ANSWER()が長い顧客レビューから具体的で実用的なインサイトをどのように抽出するかに
        注目してください。手動レビューではなく、この関数は「friendly staff was saving grace（親切な
        スタッフが救いだった）」や「hot dogs are cooked to perfection（ホットドッグは完璧に調理されている）」
        などの具体的なフィードバックを自動的に特定します。結果は、密度の高いテキストを、
        運用チームが即座に活用できる具体的で引用可能なフィードバックに変換することです。
*/

/*===================================================================================
  4. エグゼクティブサマリーの生成
  ===================================================================================
   AI_SUMMARIZE_AGG()関数を使用して、顧客フィードバックの簡潔なサマリーを作成します。
   複数のレビューを1つの要約に凝縮し、全体的なセンチメントと重要なポイントを提供します。
-----------------------------------------------------------------------------------*/

-- ビジネス上の質問: 「各トラックブランドの主要なテーマと全体的なセンチメントは何か？」

-- ============================================
-- Step 1: 要約対象のレビューを確認
-- ============================================
-- まず、どんなレビューが要約対象になるか確認します

SELECT
    truck_brand_name,
    review
FROM harmonized.truck_reviews_v
WHERE truck_brand_name = 'Kitakata Ramen Bar'  -- 1ブランドに絞って確認
LIMIT 5;

-- ============================================
-- Step 2: 1ブランドのレビューを要約
-- ============================================
-- AI_SUMMARIZE_AGG()で複数レビューを1つのサマリーに凝縮します

SELECT
    truck_brand_name,
    AI_SUMMARIZE_AGG(review) AS review_summary
FROM harmonized.truck_reviews_v
WHERE truck_brand_name = 'Kitakata Ramen Bar'
GROUP BY truck_brand_name;

-- 💡 ポイント: 複数のレビューが1つの簡潔なサマリーになりました

-- ============================================
-- Step 3: 全ブランドの要約を生成（日本語訳付き）
-- ============================================
-- AI_TRANSLATEで日本語に翻訳も可能です

SELECT
  truck_brand_name,
  AI_SUMMARIZE_AGG(review) AS review_summary,
  SNOWFLAKE.CORTEX.AI_TRANSLATE(review_summary, 'en', 'ja') AS review_summary_ja
FROM
  (
    SELECT
      truck_brand_name,
      review
    FROM
      harmonized.truck_reviews_v
    LIMIT
      100
  )
GROUP BY
  truck_brand_name;

/*
  💡 ポイント:
      AI_SUMMARIZE_AGG()は、長いレビューを明確なブランドレベルのサマリーに凝縮します。
      エグゼクティブ向けのレポートや、迅速な意思決定に活用できます。
*/

/*************************************************************************************************** 
    AI SQL関数の変革力をうまく実証しました。顧客フィードバック分析を個別のレビュー処理から
    体系的な本番規模のインテリジェンスにシフトしました。これら4つのコア関数を通じた旅は、
    それぞれが明確な分析目的を果たし、生の顧客の声を包括的なビジネスインテリジェンス
    （体系的、スケーラブル、即座に実行可能）に変換する方法を明確に示しています。
    かつて個別のレビュー分析が必要だったものが、今では数秒で数千のレビューを処理し、
    データ駆動型の運用改善に重要な感情的コンテキストと具体的な詳細の両方を提供します。
****************************************************************************************************/

-- モジュール完了！
SELECT '🎉 Module 03 完了！次は Module 04: ガバナンスに進みましょう。' AS message;

