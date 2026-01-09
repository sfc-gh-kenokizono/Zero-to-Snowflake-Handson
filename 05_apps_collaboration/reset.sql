/***************************************************************************************************
Zero to Snowflake ハンズオン - Module 05 リセット
Version: v2
Copyright(c): 2025 Snowflake Inc. All rights reserved.
****************************************************************************************************

このスクリプトは Module 05: アプリとコラボレーション で作成したオブジェクトをリセットします。

注意: Marketplaceから取得したデータベース（ZTS_WEATHERSOURCE, ZTS_SAFEGRAPH）は
      このスクリプトでは削除されません。手動で削除してください。

****************************************************************************************************/

USE ROLE accountadmin;
USE DATABASE tb_101;

-- ビューを削除
DROP VIEW IF EXISTS harmonized.daily_weather_v;
DROP VIEW IF EXISTS analytics.daily_sales_by_weather_v;
DROP VIEW IF EXISTS harmonized.tastybytes_poi_v;

-- クエリタグの設定を解除
ALTER SESSION UNSET query_tag;

-- ウェアハウスを一時停止（コメントアウト: AUTO_SUSPEND=60で自動停止するためエラー回避）
-- ALTER WAREHOUSE tb_de_wh SUSPEND;

-- リセット完了メッセージ
SELECT '✅ Module 05 のリセットが完了しました。' AS message;

/*
    Marketplaceデータベースを削除する場合は、以下を実行してください:
    
    DROP DATABASE IF EXISTS zts_weathersource;
    DROP DATABASE IF EXISTS zts_safegraph;
*/

