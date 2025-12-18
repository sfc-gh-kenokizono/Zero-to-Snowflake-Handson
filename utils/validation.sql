/***************************************************************************************************
Zero to Snowflake ハンズオン - セットアップ検証SQL
Version: v2
Copyright(c): 2025 Snowflake Inc. All rights reserved.
****************************************************************************************************

このスクリプトは、ハンズオン環境が正しくセットアップされているかを検証します。
各チェックが成功すると ✅ が表示されます。

****************************************************************************************************/

USE ROLE accountadmin;

/*===================================================================================
  データベース・スキーマの検証
===================================================================================*/

-- データベースの確認
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✅' ELSE '❌' END AS status,
    'TB_101 Database' AS check_item,
    CASE WHEN COUNT(*) > 0 THEN 'OK' ELSE 'NOT FOUND' END AS result
FROM INFORMATION_SCHEMA.DATABASES
WHERE DATABASE_NAME = 'TB_101';

-- スキーマの確認
SELECT 
    CASE WHEN COUNT(*) >= 7 THEN '✅' ELSE '❌' END AS status,
    'Schemas (expected: 7+)' AS check_item,
    COUNT(*) || ' schemas found' AS result
FROM TB_101.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME IN ('RAW_POS', 'RAW_CUSTOMER', 'RAW_SUPPORT', 'HARMONIZED', 'ANALYTICS', 'GOVERNANCE', 'SEMANTIC_LAYER');

/*===================================================================================
  テーブルデータの検証
===================================================================================*/

USE DATABASE tb_101;

-- order_headerの行数確認（約6,200万行）
SELECT 
    CASE WHEN COUNT(*) > 60000000 THEN '✅' ELSE '❌' END AS status,
    'order_header rows' AS check_item,
    TO_VARCHAR(COUNT(*), '999,999,999') || ' rows' AS result
FROM raw_pos.order_header;

-- order_detailの行数確認
SELECT 
    CASE WHEN COUNT(*) > 100000000 THEN '✅' ELSE '❌' END AS status,
    'order_detail rows' AS check_item,
    TO_VARCHAR(COUNT(*), '999,999,999') || ' rows' AS result
FROM raw_pos.order_detail;

-- customer_loyaltyの行数確認
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✅' ELSE '❌' END AS status,
    'customer_loyalty rows' AS check_item,
    TO_VARCHAR(COUNT(*), '999,999,999') || ' rows' AS result
FROM raw_customer.customer_loyalty;

-- truck_reviewsの行数確認
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✅' ELSE '❌' END AS status,
    'truck_reviews rows' AS check_item,
    TO_VARCHAR(COUNT(*), '999,999,999') || ' rows' AS result
FROM raw_support.truck_reviews;

/*===================================================================================
  ウェアハウスの検証
===================================================================================*/

SELECT 
    CASE WHEN COUNT(*) >= 4 THEN '✅' ELSE '❌' END AS status,
    'Warehouses (expected: 4)' AS check_item,
    COUNT(*) || ' warehouses found' AS result
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID(-1)))
UNION ALL
SELECT 
    CASE WHEN COUNT(*) >= 4 THEN '✅' ELSE '❌' END AS status,
    'Warehouses' AS check_item,
    LISTAGG(name, ', ') AS result
FROM (SHOW WAREHOUSES LIKE 'TB_%');

-- 個別ウェアハウス確認
SHOW WAREHOUSES LIKE 'TB_%';

/*===================================================================================
  ロールの検証
===================================================================================*/

SELECT 
    CASE WHEN COUNT(*) >= 4 THEN '✅' ELSE '❌' END AS status,
    'Roles (expected: 4)' AS check_item,
    COUNT(*) || ' roles found' AS result
FROM (SHOW ROLES LIKE 'TB_%');

-- 個別ロール確認
SHOW ROLES LIKE 'TB_%';

/*===================================================================================
  ビューの検証
===================================================================================*/

-- harmonized.orders_vの確認
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✅' ELSE '❌' END AS status,
    'harmonized.orders_v' AS check_item,
    'View exists and has data' AS result
FROM harmonized.orders_v
LIMIT 1;

-- analytics.orders_vの確認
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✅' ELSE '❌' END AS status,
    'analytics.orders_v' AS check_item,
    'View exists and has data' AS result
FROM analytics.orders_v
LIMIT 1;

/*===================================================================================
  Cortex検索サービスの検証
===================================================================================*/

SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✅' ELSE '❌' END AS status,
    'Cortex Search Service' AS check_item,
    'tasty_bytes_review_search exists' AS result
FROM (SHOW CORTEX SEARCH SERVICES IN SCHEMA harmonized)
WHERE "name" = 'TASTY_BYTES_REVIEW_SEARCH';

/*===================================================================================
  Cortex AI機能の検証
===================================================================================*/

-- SENTIMENT関数のテスト
SELECT 
    CASE WHEN sentiment IS NOT NULL THEN '✅' ELSE '❌' END AS status,
    'CORTEX.SENTIMENT function' AS check_item,
    'Score: ' || ROUND(sentiment, 2) AS result
FROM (
    SELECT SNOWFLAKE.CORTEX.SENTIMENT('This food is amazing!') AS sentiment
);

/*===================================================================================
  ステージの検証
===================================================================================*/

SELECT 
    CASE WHEN COUNT(*) >= 2 THEN '✅' ELSE '❌' END AS status,
    'External Stages' AS check_item,
    COUNT(*) || ' stages found' AS result
FROM (SHOW STAGES IN SCHEMA public);

/*===================================================================================
  検証サマリー
===================================================================================*/

SELECT '========================================' AS summary;
SELECT '  セットアップ検証完了' AS summary;
SELECT '  すべてのチェックが ✅ であれば準備完了です' AS summary;
SELECT '========================================' AS summary;

