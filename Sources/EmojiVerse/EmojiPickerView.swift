import SwiftUI

/// 絵文字ピッカービュー
public struct EmojiPickerView: View {
  @State private var selectedCategory: EmojiCategory
  @State private var searchText: String = ""
  private let categories: [EmojiCategory]
  private let onEmojiSelected: (EmojiItem) -> Void
  private let recordFrequency: Bool

  /// デフォルトのカテゴリーを使用する初期化
  /// - Parameters:
  ///   - onEmojiSelected: 絵文字が選択されたときのコールバック
  ///   - recordFrequency: 使用履歴を記録するかどうか（デフォルト: false）
  ///   - customEmojiBaseUrl: カスタム絵文字画像のベース URL（オプショナル）
  public init(
    onEmojiSelected: @escaping (EmojiItem) -> Void, recordFrequency: Bool = false,
    customEmojiBaseUrl: String? = nil
  ) {
    let defaultCategories = EmojiData.getDefaultCategories()
    self.categories = Self.applyCustomImageUrls(
      to: defaultCategories, baseUrl: customEmojiBaseUrl)
    self._selectedCategory = State(initialValue: self.categories.first!)
    self.onEmojiSelected = onEmojiSelected
    self.recordFrequency = recordFrequency
  }

  /// カスタムカテゴリーを使用する初期化
  /// - Parameters:
  ///   - categories: 表示するカテゴリーのリスト
  ///   - onEmojiSelected: 絵文字が選択されたときのコールバック
  ///   - recordFrequency: 使用履歴を記録するかどうか（デフォルト: false）
  ///   - customEmojiBaseUrl: カスタム絵文字画像のベース URL（オプショナル）
  public init(
    categories: [EmojiCategory], onEmojiSelected: @escaping (EmojiItem) -> Void,
    recordFrequency: Bool = false, customEmojiBaseUrl: String? = nil
  ) {
    self.categories = Self.applyCustomImageUrls(to: categories, baseUrl: customEmojiBaseUrl)
    self._selectedCategory = State(initialValue: self.categories.first!)
    self.onEmojiSelected = onEmojiSelected
    self.recordFrequency = recordFrequency
  }

  /// 指定されたカテゴリータイプのみを表示する初期化
  /// - Parameters:
  ///   - categoryTypes: 表示するカテゴリータイプ
  ///   - onEmojiSelected: 絵文字が選択されたときのコールバック
  ///   - recordFrequency: 使用履歴を記録するかどうか（デフォルト: false）
  ///   - customEmojiBaseUrl: カスタム絵文字画像のベース URL（オプショナル）
  public init(
    categoryTypes: [EmojiCategoryType], onEmojiSelected: @escaping (EmojiItem) -> Void,
    recordFrequency: Bool = false, customEmojiBaseUrl: String? = nil
  ) {
    let filteredCategories = EmojiData.getCategories(types: categoryTypes)
    self.categories = Self.applyCustomImageUrls(
      to: filteredCategories, baseUrl: customEmojiBaseUrl)
    self._selectedCategory = State(initialValue: self.categories.first!)
    self.onEmojiSelected = onEmojiSelected
    self.recordFrequency = recordFrequency
  }

  public var body: some View {
    VStack(spacing: 0) {
      // 検索バー
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.secondary)
          .font(.system(size: 16))
        TextField("絵文字を検索", text: $searchText)
          .textFieldStyle(.plain)
          .font(.system(size: 16))
        if !searchText.isEmpty {
          Button {
            searchText = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.secondary)
              .font(.system(size: 16))
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color(uiColor: .systemBackground))

      Divider()

      // カテゴリー選択バー（検索中は無効化）
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(categories) { category in
            EmojiCategoryButton(
              category: category,
              isSelected: selectedCategory.id == category.id
            ) {
              selectedCategory = category
            }
            .disabled(isSearching)
            .opacity(isSearching ? 0.5 : 1.0)
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
      }
      .background(Color(uiColor: .systemBackground))

      Divider()

      // 絵文字グリッド - 検索中は検索結果、通常時はカテゴリー別表示
      if isSearching {
        // 検索結果を表示
        EmojiGridView(category: searchResultCategory, onEmojiSelected: handleEmojiSelection)
      } else {
        // 全カテゴリーを保持してスクロール位置を維持
        ZStack {
          ForEach(categories) { category in
            EmojiGridView(category: category, onEmojiSelected: handleEmojiSelection)
              .opacity(selectedCategory.id == category.id ? 1 : 0)
              .allowsHitTesting(selectedCategory.id == category.id)
          }
        }
      }
    }
  }

  /// 絵文字選択時の処理
  private func handleEmojiSelection(_ emoji: EmojiItem) {
    // 使用履歴を記録（Unicode 絵文字とカスタム絵文字）
    if recordFrequency {
      switch emoji.type {
      case .unicode(let text):
        EmojiFrequencyManager.shared.recordUsage(emoji: text)
      case .url(let url):
        EmojiFrequencyManager.shared.recordUsage(
          customEmojiId: emoji.id, url: url.absoluteString)
      case .image:
        // 画像タイプは記録しない
        break
      }
    }

    // コールバックを呼び出し
    onEmojiSelected(emoji)
  }

  // MARK: - Computed Properties

  /// 検索中かどうか
  private var isSearching: Bool {
    !searchText.trimmingCharacters(in: .whitespaces).isEmpty
  }

  /// 検索結果カテゴリー
  private var searchResultCategory: EmojiCategory {
    let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
    var searchResults: [EmojiItem] = []

    // 全カテゴリーから絵文字を検索
    for category in categories {
      for emoji in category.emojis {
        // ID（絵文字文字列）での完全一致
        if emoji.id.lowercased().contains(query) {
          searchResults.append(emoji)
          continue
        }

        // キーワードでの部分一致
        if emoji.keywords.contains(where: { $0.lowercased().contains(query) }) {
          searchResults.append(emoji)
        }
      }
    }

    return EmojiCategory(
      id: "search_results",
      title: "検索結果",
      icon: "magnifyingglass",
      emojis: searchResults
    )
  }

  // MARK: - Helper Methods

  /// カテゴリー内の Unicode 絵文字にカスタム画像 URL を適用
  /// - Parameters:
  ///   - categories: 対象のカテゴリー
  ///   - baseUrl: カスタム絵文字画像のベース URL
  /// - Returns: カスタム画像 URL が適用されたカテゴリー
  private static func applyCustomImageUrls(
    to categories: [EmojiCategory], baseUrl: String?
  ) -> [EmojiCategory] {
    guard let baseUrl = baseUrl else {
      // ベース URL がない場合はそのまま返す
      return categories
    }

    return categories.map { category in
      let updatedEmojis = category.emojis.map { emoji -> EmojiItem in
        // Unicode 絵文字のみカスタム画像 URL を設定
        if case .unicode(let text) = emoji.type,
          let customUrl = makeCustomEmojiUrl(
            for: text, baseUrl: baseUrl)
        {
          return EmojiItem.unicode(
            text, keywords: emoji.keywords, customImageUrl: customUrl)
        }
        return emoji
      }

      return EmojiCategory(
        id: category.id,
        title: category.title,
        icon: category.icon,
        emojis: updatedEmojis
      )
    }
  }

  /// Unicode 絵文字からカスタム画像 URL を生成
  /// - Parameters:
  ///   - emoji: Unicode 絵文字文字列
  ///   - baseUrl: ベース URL またはローカルファイルパス（Bundle リソース内のディレクトリパス）
  /// - Returns: カスタム画像の URL
  private static func makeCustomEmojiUrl(for emoji: String, baseUrl: String) -> URL? {
    let codepoint = emoji.unicodeCodepoints

    // HTTP/HTTPS URL の場合
    if baseUrl.hasPrefix("http://") || baseUrl.hasPrefix("https://") {
      return URL(string: "\(baseUrl)/\(codepoint).png")
    }

    // ローカルファイルパスの場合（Bundle のリソースから読み込む）
    // Bundle.main.url(forResource:withExtension:subdirectory:) を使用
    let url = Bundle.main.url(forResource: codepoint, withExtension: "png", subdirectory: baseUrl)

    #if DEBUG
      if url == nil {
        print("⚠️ Failed to find resource: \(codepoint).png in subdirectory: \(baseUrl)")
        // Bundle のリソースパスを確認
        if let resourcePath = Bundle.main.resourcePath {
          print("📁 Bundle resource path: \(resourcePath)")
          // サブディレクトリのパスを確認
          let fullPath = "\(resourcePath)/\(baseUrl)/\(codepoint).png"
          print("📂 Looking for: \(fullPath)")
          let fileExists = FileManager.default.fileExists(atPath: fullPath)
          print("📄 File exists: \(fileExists)")
        }
      } else {
        print("✅ Found resource URL: \(url!)")
      }
    #endif

    return url
  }
}

// MARK: - Preview

#Preview {
  EmojiPickerView { emoji in
    print("Selected emoji: \(emoji.id)")
  }
  .frame(height: 400)
}

#Preview("Custom Categories") {
  // カスタムカテゴリーを追加した例
  let customCategory = EmojiCategory(
    id: "custom",
    title: "カスタム",
    icon: "star.fill",
    emojis: [
      EmojiItem.url(
        id: "kawaii",
        url: URL(string: "https://static.natsuneko.com/images/reactions/kawaii.png")!
      ),
      EmojiItem.url(
        id: "ohayo",
        url: URL(string: "https://static.natsuneko.com/images/reactions/ohayo.png")!
      ),
    ]
  )

  let categories = [customCategory] + EmojiData.getDefaultCategories()

  return EmojiPickerView(categories: categories) { emoji in
    print("Selected emoji: \(emoji.id)")
  }
  .frame(height: 400)
}

#Preview("Filtered Categories") {
  // 特定のカテゴリーのみを表示
  EmojiPickerView(
    categoryTypes: [
      .smileysAndPeople,
      .animalsAndNature,
      .foodAndDrink,
    ]
  ) { emoji in
    print("Selected emoji: \(emoji.id)")
  }
  .frame(height: 400)
}

#Preview("Custom Emoji Images (from Internet)") {
  // カスタム絵文字画像 URL を使用した例
  EmojiPickerView(
    onEmojiSelected: { emoji in
      print("Selected emoji: \(emoji.id)")
    },
    customEmojiBaseUrl: "https://static.natsuneko.com/images/reactions"
  )
  .frame(height: 400)
}

#Preview("Custom Emoji Images (from Local Files)") {
  // ローカルファイルパスを使用した例
  // subdirectory なし（Bundle のルートから読み込む）
  EmojiPickerView(
    onEmojiSelected: { emoji in
      print("Selected emoji: \(emoji.id)")
    },
    customEmojiBaseUrl: ""  // Bundle ルートの 1f436.png などが読み込まれます
  )
  .frame(height: 400)
}
