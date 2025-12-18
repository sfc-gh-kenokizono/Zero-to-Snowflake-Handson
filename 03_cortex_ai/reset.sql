/***************************************************************************************************
Zero to Snowflake ハンズオン - Module 03 リセット
Version: v2
Copyright(c): 2025 Snowflake Inc. All rights reserved.
****************************************************************************************************

このスクリプトは Module 03: Cortex AI で作成したオブジェクトをリセットします。
（このモジュールは主にSELECTクエリのため、リセット対象は最小限です）

****************************************************************************************************/

USE ROLE accountadmin;
USE DATABASE tb_101;

-- クエリタグの設定を解除
ALTER SESSION UNSET query_tag;

-- ウェアハウスを一時停止
ALTER WAREHOUSE tb_analyst_wh SUSPEND;

-- リセット完了メッセージ
SELECT '✅ Module 03 のリセットが完了しました。' AS message;

