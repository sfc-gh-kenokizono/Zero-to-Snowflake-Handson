/***************************************************************************************************
Zero to Snowflake ハンズオン - Module 02 リセット
Version: v2
Copyright(c): 2025 Snowflake Inc. All rights reserved.
****************************************************************************************************

このスクリプトは Module 02: シンプルなデータパイプライン で作成したオブジェクトをリセットします。

****************************************************************************************************/

USE ROLE accountadmin;
USE DATABASE tb_101;

-- Dynamic Tablesを削除
DROP DYNAMIC TABLE IF EXISTS harmonized.ingredient_usage_by_truck;
DROP DYNAMIC TABLE IF EXISTS harmonized.ingredient_to_menu_lookup;
DROP DYNAMIC TABLE IF EXISTS harmonized.ingredient;

-- ステージングテーブルを削除
DROP TABLE IF EXISTS raw_pos.menu_staging;

-- テスト用に挿入したデータを削除
DELETE FROM raw_pos.order_detail
WHERE order_detail_id = 904745311;

DELETE FROM raw_pos.order_header
WHERE order_id = 459520441;

-- クエリタグの設定を解除
ALTER SESSION UNSET query_tag;

-- ウェアハウスを一時停止
ALTER WAREHOUSE tb_de_wh SUSPEND;

-- リセット完了メッセージ
SELECT '✅ Module 02 のリセットが完了しました。' AS message;

