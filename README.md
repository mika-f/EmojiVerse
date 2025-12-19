# EmojiVerse

An OSS component for SwiftUI that provides a Discord/Slack-style categorized emoji picker. Handle both Unicode emojis and custom reactions in a single view.

| Default | Search Emojis | Custom Emojis | Use Twemoji as Render |
| ------- | ------------- | ------------- | --------------------- |
| ![](https://images.natsuneko.com/cf5f57c0395effa16d5c9bb3e9e9985b95cb9033ae40ffe342742536d7141f61.jpg) | ![](https://images.natsuneko.com/99a70cb8bb8c4ccd1932db316b26ab86929f3e2f25377113b79a8c7817394f9e.jpg) | ![](https://images.natsuneko.com/142e744f359b1bf367e5b495c76a48df9be2e0a215a58be10f85c2cd0e73f4ea.jpg) | ![](https://images.natsuneko.com/46f01f00445a118c1f546a5d1e0e1a39245a26172df98525b85078c52918bf3b.jpg) |

## Highlights

- ✅ Supports 3 emoji sources: Native Unicode, External URL, and `UIImage`
- ✅ Category tabs, search bar, and 8-column grid layout with LazyVGrid
- ✅ Recently used emoji tracking + UserDefaults persistence
- ✅ Easy addition/removal of custom categories and custom icons
- ✅ Support for custom image CDN / Bundle resources
- ✅ Automatic parsing of official Unicode data (emoji-test.txt v16.0) via EmojiTestParser

## Requirements

- Xcode 15.4 / Swift 5.10 or later
- iOS 17.0+, iPadOS 17.0+, macOS 14.0+ (works in any environment that supports SwiftUI)
- Uses `UserDefaults` to persist recently used emojis

## Installation

To integrate using Swift Package Manager, add the following to your `Package.swift`:

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

`EmojiPickerView` is the main component of EmojiVerse. The callback receives an `EmojiItem`, allowing you to implement custom actions based on the selected emoji type (Unicode / URL / UIImage).

## Customization

### 1. Add Custom Categories

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

### 2. Exclude Unnecessary Categories

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

### 3. Apply Custom Emoji Images

Using `customEmojiBaseUrl`, you can load images from a CDN or Bundle resources. Place images using Unicode code points as filenames (e.g., `1f436`).

```swift
EmojiPickerView(
  onEmojiSelected: handleEmojiSelection,
  customEmojiBaseUrl: "https://cdn.example.com/emojis"
)
```

### 4. Modify Grid Appearance

You can adjust the number of columns and cell size in `EmojiGridView.swift`.

```swift
private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)
private let emojiSize: CGFloat = 40
```

## Integration Example

Minimal example for calling from a sheet or popover:

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
    // Implement network posting or view dismissal
  }
}
```

## Architecture

```
EmojiPicker/
├── EmojiItem.swift              // Emoji model
├── EmojiCategory.swift          // Category definition + SFSymbol icons
├── EmojiData.swift              // Unicode data loading and caching
├── EmojiFrequencyManager.swift  // Persistence of recently used emojis
├── EmojiTestParser.swift        // emoji-test.txt parser
├── EmojiCategoryButton.swift    // Category bar
├── EmojiGridView.swift          // LazyVGrid layout
├── String+Unicode.swift         // Code point conversion utilities
└── EmojiPickerView.swift        // Main view
```

## Emoji Dataset

- `EmojiTestParser` generates `EmojiData` based on the official Unicode `emoji-test.txt` v16.0
- Reference URL: https://unicode.org/Public/emoji/16.0/emoji-test.txt
- Retrieved on: 2024-08-14
- Uses only fully-qualified entries (approximately 4,000 entries)

After replacing `Resources/emoji-test.txt` with a newer version, call `EmojiData.clearCache()` to retrieve the latest re-parsed data.

## Recent / Frequency Emoji

Specifying `EmojiPickerView(recordFrequency: true)` will save up to 30 recently used Unicode/URL emojis via `EmojiFrequencyManager`.

```swift
if let recent = EmojiData.getFrequencyCategory() {
  categories.insert(recent, at: 0)
}

EmojiFrequencyManager.shared.clearHistory()        // Clear history
let recents = EmojiFrequencyManager.shared.getRecentEmojis()
```

## Roadmap

- [x] Recently used emoji category
- [x] Official support for emoji search UI (currently beta)
- [ ] Skin tone / variant selection
- [ ] Favorite pinning
- [ ] Scrolling with category sections + Sticky Header

## License

EmojiVerse is released under the [MIT License](./LICENSE).
