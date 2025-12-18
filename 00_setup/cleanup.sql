/***************************************************************************************************
Zero to Snowflake ハンズオン - 環境クリーンアップ
Version: v2
Copyright(c): 2025 Snowflake Inc. All rights reserved.
****************************************************************************************************

⚠️ 警告: このスクリプトはハンズオン環境を完全に削除します。
実行前に、必要なデータがバックアップされていることを確認してください。

削除されるオブジェクト:
- データベース: TB_101, SNOWFLAKE_INTELLIGENCE
- ウェアハウス: TB_DE_WH, TB_DEV_WH, TB_ANALYST_WH, TB_CORTEX_WH
- ロール: TB_ADMIN, TB_DATA_ENGINEER, TB_DEV, TB_ANALYST
- Marketplaceデータ: ZTS_WEATHERSOURCE, ZTS_SAFEGRAPH（取得済みの場合）

****************************************************************************************************/

-- ACCOUNTADMINロールで実行
USE ROLE ACCOUNTADMIN;

/*--
 • データベースの削除
--*/

-- メインデータベースの削除
DROP DATABASE IF EXISTS tb_101;

-- Snowflake Intelligenceデータベースの削除
DROP DATABASE IF EXISTS snowflake_intelligence;

-- Marketplaceから取得したデータベースの削除（取得済みの場合）
DROP DATABASE IF EXISTS zts_weathersource;
DROP DATABASE IF EXISTS zts_safegraph;

/*--
 • ウェアハウスの削除
--*/

DROP WAREHOUSE IF EXISTS tb_de_wh;
DROP WAREHOUSE IF EXISTS tb_dev_wh;
DROP WAREHOUSE IF EXISTS tb_analyst_wh;
DROP WAREHOUSE IF EXISTS tb_cortex_wh;

/*--
 • ロールの削除
--*/

USE ROLE securityadmin;

-- ロール階層を考慮して、下位ロールから削除
DROP ROLE IF EXISTS tb_analyst;
DROP ROLE IF EXISTS tb_dev;
DROP ROLE IF EXISTS tb_data_engineer;
DROP ROLE IF EXISTS tb_admin;
DROP ROLE IF EXISTS tb_data_steward;

/*--
 • アカウント設定のリセット（オプション）
--*/

USE ROLE accountadmin;

-- Cortexクロスリージョン設定をリセット（必要に応じて）
-- ALTER ACCOUNT UNSET CORTEX_ENABLED_CROSS_REGION;

/*--
 クリーンアップ完了メッセージ
--*/
SELECT '✅ クリーンアップが完了しました。環境が削除されました。' AS message;

