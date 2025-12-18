# Module 05: アプリとコラボレーション

Snowflake Marketplaceからのサードパーティデータ取得と、外部データを活用した分析手法を学びます。

---

## 📋 概要

**所要時間**: 約30分

### 学習目標

このモジュールを完了すると、以下ができるようになります：

- ✅ Snowflake Marketplaceからデータを取得
- ✅ サードパーティデータと自社データの統合
- ✅ Weather Sourceデータを活用した分析
- ✅ Safegraph POIデータの活用

---

## 📚 トピック

### 1. Snowflake Marketplace

**概要**: サードパーティのデータ、アプリケーション、AI製品を発見・アクセスできる集中ハブ

**特徴**:
- データのコピー不要（ライブアクセス）
- 即座にクエリ可能
- 常に最新データにアクセス

### 2. Weather Sourceデータ

**提供内容**:
- 日次天気履歴データ
- 気温、降水量、風速など
- 郵便番号レベルの粒度

**ビジネス活用**:
- 天気と売上の相関分析
- 需要予測の精度向上
- 在庫最適化

### 3. Safegraph POIデータ

**提供内容**:
- Point of Interest（POI）データ
- 店舗・施設情報
- 営業時間、カテゴリ

**ビジネス活用**:
- ロケーション分析
- 商圏分析
- 出店計画

---

## 🔧 ハンズオン手順

### Step 1: Weather Sourceデータの取得

1. Marketplaceにアクセス
2. 「Weather Source frostbyte」を検索
3. データを取得（データベース名: `ZTS_WEATHERSOURCE`）

### Step 2: Weather Sourceデータとの統合

1. 日次天気ビューを作成
2. 売上データと結合
3. 天気×売上の分析を実行

### Step 3: Safegraph POIデータの取得

1. Marketplaceで「Safegraph frostbyte」を検索
2. データを取得（データベース名: `ZTS_SAFEGRAPH`）

### Step 4: POIデータを活用した分析

1. POIビューを作成
2. 天気データと結合
3. ロケーション別分析を実行

---

## 📁 ファイル構成

| ファイル | 説明 |
|---------|------|
| `apps_collaboration.sql` | メインSQLスクリプト |
| `reset.sql` | モジュールのリセットスクリプト |
| `slides/` | スライド資料 |

---

## 🌐 Marketplace取得手順（詳細）

### Weather Source データ

1. **Snowsightにログイン**
   - アカウントレベルのロールを`ACCOUNTADMIN`に設定

2. **Marketplaceにアクセス**
   - 左メニューから「Marketplace」をクリック

3. **データを検索**
   - 検索バーに「Weather Source frostbyte」と入力

4. **リストを選択**
   - 「Weather Source LLC: frostbyte」をクリック
   - 「Get」をクリック

5. **オプション設定**
   - 「Options」をクリック
   - データベース名: `ZTS_WEATHERSOURCE`
   - アクセス権限: `PUBLIC`

6. **取得完了**
   - 「Get」をクリックして完了

### Safegraph データ

同様の手順で「Safegraph frostbyte」を取得
- データベース名: `ZTS_SAFEGRAPH`

---

## 📊 分析ユースケース

### 天気と売上の相関分析

```
┌─────────────────┐     ┌─────────────────┐
│   Orders Data   │     │  Weather Data   │
│   (TB_101)     │     │ (Marketplace)   │
└────────┬────────┘     └────────┬────────┘
         │                       │
         │    ┌─────────┐       │
         └───→│  JOIN   │←──────┘
              └────┬────┘
                   │
                   ▼
         ┌─────────────────┐
         │ 天気×売上分析   │
         │                 │
         │ • 気温と売上    │
         │ • 雨と客足     │
         │ • 風速と安全   │
         └─────────────────┘
```

### ビジネス上の質問例

1. **天気の影響**: 「シアトルで大雨の日の売上はどう変化するか？」
2. **季節性**: 「ハンブルクの2月の平均気温と売上の関係は？」
3. **リスク分析**: 「最も風が強いロケーションはどこか？」

---

## ⚠️ 注意事項

### Marketplaceデータ取得

- `ACCOUNTADMIN`ロールが必要
- 取得後、即座にクエリ可能
- データは自動的に最新状態に維持

### データ使用条件

- Marketplaceのデータには使用条件があります
- 商用利用前にライセンスを確認してください

---

## 🔄 リセット

このモジュールで作成したオブジェクトをクリーンアップする場合：

```sql
-- reset.sql を実行
```

**注意**: Marketplaceから取得したデータベースは手動で削除する必要があります。

---

## ✅ 確認問題

1. Snowflake Marketplaceのデータ共有の特徴は何ですか？

2. 天気データを売上分析に活用する方法を3つ挙げてください。

3. POIデータはどのようなビジネス課題に活用できますか？

---

## 📖 参考リンク

- [Snowflake Marketplace](https://docs.snowflake.com/en/user-guide/data-sharing-intro)
- [Weather Source](https://www.weathersource.com/)
- [Safegraph](https://www.safegraph.com/)

---

## 🎉 ハンズオン完了！

おめでとうございます！Zero to Snowflake ハンズオンのすべてのモジュールを完了しました。

### 習得したスキル

- ✅ ウェアハウス管理とコスト最適化
- ✅ データパイプライン構築（Dynamic Tables）
- ✅ AI/ML機能（Cortex AI）
- ✅ データガバナンス（Horizon）
- ✅ データコラボレーション（Marketplace）

### 次のステップ

- [Snowflake Quickstarts](https://quickstarts.snowflake.com/) で更に学習
- [Snowflake Documentation](https://docs.snowflake.com/) で詳細を確認
- 実際のプロジェクトで活用！

