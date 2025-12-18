# アーキテクチャ概要

Zero to Snowflake ハンズオンで使用するアーキテクチャの詳細説明です。

---

## 🏗️ 全体アーキテクチャ

```mermaid
flowchart TB
    subgraph ACCOUNT["☁️ Snowflake Account"]
        subgraph DB["🗄️ TB_101 Database"]
            subgraph RAW["Raw Layer"]
                RAW_POS["raw_pos<br/>country, franchise, location,<br/>menu, truck, order_header, order_detail"]
                RAW_CUST["raw_customer<br/>customer_loyalty"]
                RAW_SUP["raw_support<br/>truck_reviews"]
            end
            
            subgraph HARM["Harmonized Layer"]
                HARM_V["harmonized<br/>orders_v, customer_loyalty_metrics_v,<br/>truck_reviews_v, daily_weather_v,<br/>tastybytes_poi_v, ingredient (DT),<br/>ingredient_to_menu_lookup (DT),<br/>ingredient_usage_by_truck (DT)"]
            end
            
            subgraph ANAL["Analytics Layer"]
                ANAL_V["analytics<br/>orders_v, customer_loyalty_metrics_v,<br/>truck_reviews_v, daily_sales_by_weather_v"]
            end
            
            subgraph GOV["Governance & Semantic"]
                GOV_S["governance<br/>pii tag, policies, DMF"]
                SEM_S["semantic_layer<br/>orders_v, customer_metrics_v"]
            end
        end
        
        subgraph MKT["📦 External Data (Marketplace)"]
            WS["ZTS_WEATHERSOURCE<br/>history_day, postal_codes"]
            SG["ZTS_SAFEGRAPH<br/>frostbyte_tb_safegraph_s"]
        end
    end
    
    RAW_POS --> HARM_V
    RAW_CUST --> HARM_V
    RAW_SUP --> HARM_V
    HARM_V --> ANAL_V
    WS -.-> HARM_V
    SG -.-> HARM_V
```

---

## 👥 ロール階層

```mermaid
flowchart TB
    ACCT["ACCOUNTADMIN"]
    SEC["SECURITYADMIN"]
    SYS["SYSADMIN"]
    USER["USERADMIN"]
    TBA["TB_ADMIN"]
    TBDE["TB_DATA_ENGINEER"]
    TBD["TB_DEV"]
    TBAN["TB_ANALYST"]
    TBDS["TB_DATA_STEWARD<br/>(Module 04で作成)"]
    
    ACCT --> SEC
    ACCT --> SYS
    ACCT --> USER
    SYS --> TBA
    SEC --> TBDS
    TBA --> TBDE
    TBDE --> TBD
    TBDE --> TBAN
```

### ロール説明

| ロール | 説明 | 主な権限 |
|--------|------|----------|
| `ACCOUNTADMIN` | 最上位管理者 | すべての権限 |
| `SYSADMIN` | システム管理者 | WH/DB作成 |
| `SECURITYADMIN` | セキュリティ管理者 | ロール/権限管理 |
| `TB_ADMIN` | TB管理者 | TB環境の管理 |
| `TB_DATA_ENGINEER` | データエンジニア | ETL/パイプライン |
| `TB_DEV` | 開発者 | 開発環境アクセス |
| `TB_ANALYST` | アナリスト | 分析クエリ |
| `TB_DATA_STEWARD` | データスチュワード | ガバナンス管理 |

---

## 🗄️ スキーマ構成

### raw_pos（生データ - POS）

| テーブル | 説明 | 主要カラム |
|----------|------|-----------|
| `country` | 国・都市マスタ | country_id, country, city |
| `franchise` | フランチャイズ情報 | franchise_id, first_name, last_name |
| `location` | ロケーション情報 | location_id, city, country |
| `menu` | メニュー情報 | menu_id, menu_item_name, sale_price |
| `truck` | トラック情報 | truck_id, primary_city, franchise_id |
| `order_header` | 注文ヘッダー | order_id, truck_id, order_ts |
| `order_detail` | 注文明細 | order_detail_id, order_id, quantity |

### raw_customer（生データ - 顧客）

| テーブル | 説明 | 主要カラム |
|----------|------|-----------|
| `customer_loyalty` | ロイヤルティ会員 | customer_id, first_name, email |

### raw_support（生データ - サポート）

| テーブル | 説明 | 主要カラム |
|----------|------|-----------|
| `truck_reviews` | トラックレビュー | review_id, review, language |

### harmonized（統合データ）

| オブジェクト | タイプ | 説明 |
|-------------|--------|------|
| `orders_v` | View | 注文統合ビュー |
| `customer_loyalty_metrics_v` | View | 顧客メトリクス |
| `truck_reviews_v` | View | レビュー統合 |
| `daily_weather_v` | View | 日次天気 |
| `tastybytes_poi_v` | View | POI統合 |
| `ingredient` | Dynamic Table | 成分マスタ |
| `ingredient_to_menu_lookup` | Dynamic Table | 成分→メニュー |
| `ingredient_usage_by_truck` | Dynamic Table | 成分使用量 |

### analytics（分析用）

| オブジェクト | タイプ | 説明 |
|-------------|--------|------|
| `orders_v` | View | 分析用注文ビュー |
| `customer_loyalty_metrics_v` | View | 顧客分析 |
| `truck_reviews_v` | View | レビュー分析 |
| `daily_sales_by_weather_v` | View | 天気×売上 |

---

## ⚙️ ウェアハウス構成

| ウェアハウス | サイズ | 用途 |
|-------------|--------|------|
| `TB_DE_WH` | Large→XSmall | データエンジニアリング、初期ロード |
| `TB_DEV_WH` | X-Small | 開発・テスト |
| `TB_ANALYST_WH` | Large | 分析クエリ、Cortex AI |
| `TB_CORTEX_WH` | Large | Cortex Analyst |

---

## 🔄 データフロー

### ETLパイプライン（Module 02）

```mermaid
flowchart TB
    S3["☁️ S3 Bucket"]
    STG["📁 Stage<br/>(menu_stage)"]
    TBL["📋 menu_staging<br/>(Staging Table)"]
    DT1["⚡ ingredient<br/>(Dynamic Table)"]
    DT2["⚡ ingredient_to_menu_lookup<br/>(Dynamic Table)"]
    DT3["⚡ ingredient_usage_by_truck<br/>(Dynamic Table)"]
    
    S3 -->|"COPY INTO"| STG
    STG --> TBL
    TBL --> DT1
    DT1 --> DT2
    DT2 --> DT3
```

### AI分析フロー（Module 03）

```mermaid
flowchart TB
    SRC["📝 truck_reviews_v"]
    
    SENT["🎭 SENTIMENT<br/>感情スコア (-1〜+1)"]
    CLASS["🏷️ AI_CLASSIFY<br/>カテゴリ分類"]
    EXTRACT["🔍 EXTRACT_ANSWER<br/>回答抽出"]
    SUMM["📊 AI_SUMMARIZE_AGG<br/>集約要約"]
    
    SRC --> SENT
    SRC --> CLASS
    SRC --> EXTRACT
    SRC --> SUMM
```

---

## 🛡️ セキュリティアーキテクチャ（Module 04）

```mermaid
flowchart TB
    subgraph AUTO["🔍 自動分類"]
        N["NAME"]
        E["EMAIL"]
        P["PHONE"]
    end
    
    TAG["🏷️ PIIタグ"]
    
    subgraph POL["📜 ポリシー適用"]
        MASK["🎭 マスキングポリシー"]
        RAP["🚫 行アクセスポリシー"]
        DMF["📈 DMF (品質監視)"]
    end
    
    subgraph TRUST["🛡️ トラストセンター"]
        CIS["CIS Benchmarks"]
        SEC["Security Essentials"]
        TI["Threat Intelligence"]
    end
    
    N --> TAG
    E --> TAG
    P --> TAG
    TAG --> MASK
    TAG --> RAP
    TAG --> DMF
```

---

## 🌐 外部連携（Module 05）

```mermaid
flowchart TB
    subgraph MKT["🏪 Snowflake Marketplace"]
        WS["🌤️ Weather Source<br/>history_day, postal_codes"]
        SG["📍 Safegraph<br/>POI data, location info"]
    end
    
    TB["🗄️ TB_101 Data<br/>(orders_v)"]
    
    JOIN["🔗 JOIN"]
    
    subgraph RESULT["📊 統合分析結果"]
        R1["天気 × 売上分析"]
        R2["POI × 天気分析"]
    end
    
    WS --> JOIN
    SG --> JOIN
    TB --> JOIN
    JOIN --> R1
    JOIN --> R2
```
