/***************************************************************************************************
Zero to Snowflake ハンズオン - Module 01 リセット
Version: v2
Copyright(c): 2025 Snowflake Inc. All rights reserved.
****************************************************************************************************

このスクリプトは Module 01: Snowflakeを始める で作成したオブジェクトをリセットします。

****************************************************************************************************/

USE ROLE accountadmin;
USE DATABASE tb_101;

-- リソースモニターの削除
DROP RESOURCE MONITOR IF EXISTS my_resource_monitor;

-- 予算の削除
DROP SNOWFLAKE.CORE.BUDGET IF EXISTS my_budget;

-- 開発用テーブルの削除
DROP TABLE IF EXISTS raw_pos.truck_dev;

-- truck_detailsテーブルをリセット（元の状態に戻す）
CREATE OR REPLACE TABLE raw_pos.truck_details
AS 
SELECT * EXCLUDE (year, make, model)
FROM raw_pos.truck;

-- ウェアハウスの削除
DROP WAREHOUSE IF EXISTS my_wh;

-- クエリタグの設定を解除
ALTER SESSION UNSET query_tag;

-- リセット完了メッセージ
SELECT '✅ Module 01 のリセットが完了しました。' AS message;

