# イラスト画像ダウンロード手順

予約システムのビジュアル改善のため、以下の5つのSVGイラストをダウンロードしてください。

## 調達元

**Undraw** (https://undraw.co/illustrations)
- 無料で商用利用可能なSVGイラスト
- カラー統一機能あり

## カラー設定

すべてのイラストで以下のカラーに統一してください：
- **カラーコード**: `#059669`（農協ブランドの緑色）

## 必要な画像リスト

### 1. calendar.svg - カレンダーページ用

**検索キーワード**: "calendar"
**ファイル名**: `calendar.svg`
**配置先**: `app/assets/images/illustrations/calendar.svg`
**サイズ**: 中〜大サイズ（横幅 300-500px 推奨）

**ダウンロード手順**:
1. https://undraw.co/illustrations にアクセス
2. 右上のカラーピッカーで `#059669` を入力
3. 検索バーに「calendar」を入力
4. 適切なイラスト（カレンダーや日付選択のイメージ）を選択
5. 「Download」ボタンでSVGをダウンロード
6. ファイル名を `calendar.svg` に変更してこのディレクトリに配置

---

### 2. time-selection.svg - 時間選択ページ用

**検索キーワード**: "time" または "clock"
**ファイル名**: `time-selection.svg`
**配置先**: `app/assets/images/illustrations/time-selection.svg`
**サイズ**: 中サイズ（横幅 300-400px 推奨）

**ダウンロード手順**:
1. https://undraw.co/illustrations にアクセス
2. 右上のカラーピッカーで `#059669` を入力
3. 検索バーに「time」または「clock」を入力
4. 時計や時間管理のイメージを選択
5. 「Download」ボタンでSVGをダウンロード
6. ファイル名を `time-selection.svg` に変更してこのディレクトリに配置

---

### 3. personal-info.svg - 顧客情報入力ページ用

**検索キーワード**: "form" または "personal info"
**ファイル名**: `personal-info.svg`
**配置先**: `app/assets/images/illustrations/personal-info.svg`
**サイズ**: 中サイズ（横幅 250-350px 推奨）

**ダウンロード手順**:
1. https://undraw.co/illustrations にアクセス
2. 右上のカラーピッカーで `#059669` を入力
3. 検索バーに「form」または「personal」を入力
4. フォーム入力や個人情報のイメージを選択
5. 「Download」ボタンでSVGをダウンロード
6. ファイル名を `personal-info.svg` に変更してこのディレクトリに配置

---

### 4. checklist.svg - 予約確認ページ用

**検索キーワード**: "checklist" または "confirm"
**ファイル名**: `checklist.svg`
**配置先**: `app/assets/images/illustrations/checklist.svg`
**サイズ**: 中サイズ（横幅 250-350px 推奨）

**ダウンロード手順**:
1. https://undraw.co/illustrations にアクセス
2. 右上のカラーピッカーで `#059669` を入力
3. 検索バーに「checklist」または「confirm」を入力
4. チェックリストや確認作業のイメージを選択
5. 「Download」ボタンでSVGをダウンロード
6. ファイル名を `checklist.svg` に変更してこのディレクトリに配置

---

### 5. celebration.svg - 予約完了ページ用

**検索キーワード**: "celebration" または "success"
**ファイル名**: `celebration.svg`
**配置先**: `app/assets/images/illustrations/celebration.svg`
**サイズ**: 大サイズ（横幅 400-500px 推奨）

**ダウンロード手順**:
1. https://undraw.co/illustrations にアクセス
2. 右上のカラーピッカーで `#059669` を入力
3. 検索バーに「celebration」または「success」を入力
4. 成功や祝福のイメージを選択（パーティーや達成感のあるイラスト）
5. 「Download」ボタンでSVGをダウンロード
6. ファイル名を `celebration.svg` に変更してこのディレクトリに配置

---

## 配置後の確認

すべてのファイルをダウンロードして配置したら、以下のコマンドでファイルが正しく配置されているか確認してください：

```bash
ls -la app/assets/images/illustrations/
```

以下の5つのファイルが表示されれば成功です：
- `calendar.svg`
- `time-selection.svg`
- `personal-info.svg`
- `checklist.svg`
- `celebration.svg`

---

## トラブルシューティング

### 画像が表示されない場合

1. **ファイル名を確認**
   ファイル名が完全一致しているか確認（大文字小文字も区別されます）

2. **配置場所を確認**
   `app/assets/images/illustrations/` ディレクトリ直下に配置されているか確認

3. **開発サーバーを再起動**
   ```bash
   # Ctrl+C で停止後、再起動
   bin/dev
   ```

4. **ブラウザのキャッシュをクリア**
   ブラウザのスーパーリロード（Cmd+Shift+R または Ctrl+Shift+F5）

---

## 代替案（画像がダウンロードできない場合）

もしUndrawから画像をダウンロードできない場合は、以下の代替サイトも利用できます：

- **unDraw** (https://undraw.co/) - 推奨
- **Storyset** (https://storyset.com/) - アニメーション可能
- **Illustrations** (https://illlustrations.co/) - シンプルなイラスト

いずれの場合も、カラーを `#059669`（緑）に統一することを忘れないでください。

---

最終更新日: 2025-12-28
