# EmojiVerse

SwiftUI で Discord / Slack スタイルのカテゴリー別絵文字ピッカーを実現する OSS コンポーネントです。Unicode 絵文字も、独自のカスタムリアクションもひとつのビューで扱えます。

| Default | Search Emojis | Custom Emojis | Use Twemoji as Render |
| ------- | ------------- | ------------- | --------------------- |
| ![](https://images.natsuneko.com/cf5f57c0395effa16d5c9bb3e9e9985b95cb9033ae40ffe342742536d7141f61.jpg) | ![](https://images.natsuneko.com/99a70cb8bb8c4ccd1932db316b26ab86929f3e2f25377113b79a8c7817394f9e.jpg) | ![](https://images.natsuneko.com/142e744f359b1bf367e5b495c76a48df9be2e0a215a58be10f85c2cd0e73f4ea.jpg) | ![](https://images.natsuneko.com/46f01f00445a118c1f546a5d1e0e1a39245a26172df98525b85078c52918bf3b.jpg) |

## Highlights

- ✅ ネイティブ Unicode、外部 URL、`UIImage` の 3 つの絵文字ソースをサポート
- ✅ カテゴリータブ、検索バー、LazyVGrid による 8 列グリッド表示
- ✅ 最近使用した絵文字のトラッキング + UserDefaults 永続化
- ✅ カスタムカテゴリーやカスタムアイコンの追加・削除が容易
- ✅ カスタム画像 CDN / Bundle リソースへの差し替えに対応
- ✅ EmojiTestParser による Unicode 公式データ (emoji-test.txt v16.0) の自動パース

## Requirements

- Xcode 15.4 / Swift 5.10 以降
- iOS 17.0+, iPadOS 17.0+, macOS 14.0+（SwiftUI が動作する環境であれば動作可能）
- `UserDefaults` を使用して最近使用した絵文字を永続化します

## Installation

Swift Package Manager を利用してプロジェクトに組み込む場合、`Package.swift` に以下を追加してください：

```swift
// swift-tools-version:5.10
dependencies: [
    .package(url: "https://github.com/mika-f/EmojiVerse.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftUI

struct EmojiDemo: View {
  var body: some View {
    EmojiPickerView(recordFrequency: true) { emoji in
      print("Selected emoji:", emoji.id)
    }
    .frame(height: 400)
  }
}
```

`EmojiPickerView` が EmojiVerse のメインコンポーネントです。コールバックには `EmojiItem` が渡され、選択された絵文字の種別（Unicode / URL / UIImage）に応じて任意のアクションを実装できます。

## Customization

### 1. カスタムカテゴリーを追加

```swift
let customCategory = EmojiCategory(
  id: "catalyst",
  title: "Catalyst",
  icon: "star.fill",
  emojis: [
    EmojiItem.url(
      id: "reaction1",
      url: URL(string: "https://cdn.example.com/reactions/reaction1.png")!
    ),
  ]
)

let categories = [customCategory] + EmojiData.getDefaultCategories()

EmojiPickerView(categories: categories, recordFrequency: true) { emoji in
  handleEmojiSelection(emoji)
}
```

### 2. 不要なカテゴリーを除外

```swift
EmojiPickerView(
  categoryTypes: [
    .smileysAndPeople,
    .animalsAndNature,
    .foodAndDrink,
  ]
) { emoji in
  handleEmojiSelection(emoji)
}
```

### 3. カスタム絵文字画像を適用

`customEmojiBaseUrl` で CDN や Bundle リソースから画像を読み込めます。Unicode のコードポイント（例: `1f436`）をファイル名として配置してください。

```swift
EmojiPickerView(
  onEmojiSelected: handleEmojiSelection,
  customEmojiBaseUrl: "https://cdn.example.com/emojis"
)
```

### 4. グリッドの見た目を変更

`EmojiGridView.swift` で列数やセルサイズを調整できます。

```swift
private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)
private let emojiSize: CGFloat = 40
```

## Integration Example

Sheet やポップオーバーから呼び出す最低限の例：

```swift
struct EmojiPickerSheet: View {
  var body: some View {
    EmojiPickerView { emoji in
      handleEmojiSelection(emoji)
    }
    .frame(height: 420)
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
  }

  private func handleEmojiSelection(_ emoji: EmojiItem) {
    switch emoji.type {
    case .unicode(let text):
      sendReaction(symbol: text)
    case .url(let url):
      sendReaction(symbol: ":custom:", imageUrl: url)
    case .image(let image):
      sendReaction(symbol: ":local:", uiImage: image)
    }
  }

  private func sendReaction(symbol: String, imageUrl: URL? = nil, uiImage: UIImage? = nil) {
    // ネットワーク投稿やビューの dismissal などを実装
  }
}
```

## Architecture

```
EmojiPicker/
├── EmojiItem.swift              // 絵文字モデル
├── EmojiCategory.swift          // カテゴリー定義 + SFSymbol アイコン
├── EmojiData.swift              // Unicode データ読み込みとキャッシュ
├── EmojiFrequencyManager.swift  // 最近使用した絵文字の永続化
├── EmojiTestParser.swift        // emoji-test.txt パーサー
├── EmojiCategoryButton.swift    // カテゴリーバー
├── EmojiGridView.swift          // LazyVGrid レイアウト
├── String+Unicode.swift         // コードポイント変換ユーティリティ
└── EmojiPickerView.swift        // メインビュー
```

## Emoji Dataset

- Unicode 公式 `emoji-test.txt` v16.0 をもとに `EmojiTestParser` が `EmojiData` を生成します
- 参照 URL: https://unicode.org/Public/emoji/16.0/emoji-test.txt
- 取得日: 2024-08-14
- fully-qualified のエントリのみを使用（約 4,000 件）

`Resources/emoji-test.txt` を新しいバージョンに差し替えたあと `EmojiData.clearCache()` を呼び出すと、再パースした最新データを取得できます。

## Recent / Frequency Emoji

`EmojiPickerView(recordFrequency: true)` を指定すると、`EmojiFrequencyManager` が最近使用した Unicode / URL 絵文字を最大 30 件まで保存します。

```swift
if let recent = EmojiData.getFrequencyCategory() {
  categories.insert(recent, at: 0)
}

EmojiFrequencyManager.shared.clearHistory()        // 履歴をクリア
let recents = EmojiFrequencyManager.shared.getRecentEmojis()
```

## Roadmap

- [x] Recently used emoji category
- [x] Emoji search UI の正式サポート（現在ベータ）
- [ ] スキントーン / バリアント選択
- [ ] お気に入りピン留め
- [ ] カテゴリーセクション付きスクロール + Sticky Header

## License

EmojiVerse は [MIT License](./LICENSE) のもとで公開されます。
