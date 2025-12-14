import Foundation

/// 絵文字データを提供するクラス
struct EmojiData {
    /// パースされた絵文字データのキャッシュ
    private nonisolated(unsafe) static var cachedCategories: [EmojiCategory]?
    /// キャッシュ用のシリアルキュー
    private static let cacheQueue = DispatchQueue(label: "EmojiData.cacheQueue")

    /// デフォルトのカテゴリーを取得
    static func getDefaultCategories() -> [EmojiCategory] {
        // キャッシュがあればそれを返す
        if let cached = cacheQueue.sync(execute: { cachedCategories }) {
            return cached
        }

        // emoji-test.txt からパース
        let parsedData = EmojiTestParser.parse()
        var categories: [String: EmojiCategory] = [:]

        // グループごとに処理
        for (group, emojis) in parsedData {
            guard let categoryId = EmojiTestParser.mapGroupToCategory(group) else {
                continue
            }

            // 既存のカテゴリーに追加するか、新規作成
            if var existingCategory = categories[categoryId] {
                let newEmojis = emojis.map { emoji in
                    EmojiItem.unicode(emoji.emoji, keywords: [emoji.name])
                }
                existingCategory = EmojiCategory(
                    id: existingCategory.id,
                    title: existingCategory.title,
                    icon: existingCategory.icon,
                    emojis: existingCategory.emojis + newEmojis
                )
                categories[categoryId] = existingCategory
            } else {
                // 新規カテゴリーを作成
                if let categoryType = EmojiCategoryType.allCases.first(where: {
                    $0.rawValue == categoryId
                }) {
                    let emojiItems = emojis.map { emoji in
                        EmojiItem.unicode(emoji.emoji, keywords: [emoji.name])
                    }
                    categories[categoryId] = EmojiCategory(
                        id: categoryType.rawValue,
                        title: categoryType.title,
                        icon: categoryType.icon,
                        emojis: emojiItems
                    )
                }
            }
        }

        // カテゴリーを順番通りに並べる
        let result = EmojiCategoryType.allCases.compactMap { type in
            categories[type.rawValue]
        }

        // キャッシュに保存（スレッドセーフに）
        cacheQueue.async {
            cachedCategories = result
        }

        return result
    }

    /// 指定されたカテゴリータイプのみを取得
    static func getCategories(types: [EmojiCategoryType]) -> [EmojiCategory] {
        let allCategories = getDefaultCategories()
        return allCategories.filter { category in
            types.contains { $0.rawValue == category.id }
        }
    }

    /// キャッシュをクリア（主にテスト用）
    static func clearCache() {
        cacheQueue.sync {
            cachedCategories = nil
        }
    }

    /// 最近使用した絵文字のカテゴリーを取得
    static func getFrequencyCategory() -> EmojiCategory? {
        let items = EmojiFrequencyManager.shared.getRecentEmojiItems()

        guard !items.isEmpty else {
            return nil
        }

        let emojiItems = items.map { item -> EmojiItem in
            switch item.type {
            case .unicode:
                return EmojiItem.unicode(item.value)
            case .url:
                return EmojiItem.url(id: item.id, url: URL(string: item.value)!)
            }
        }

        return EmojiCategory(
            id: EmojiCategoryType.frequency.rawValue,
            title: EmojiCategoryType.frequency.title,
            icon: EmojiCategoryType.frequency.icon,
            emojis: emojiItems
        )
    }

    /// デフォルトのカテゴリーに最近使用した絵文字を含めて取得
    static func getCategoriesWithFrequency() -> [EmojiCategory] {
        var categories: [EmojiCategory] = []

        // 最近使用した絵文字カテゴリーを先頭に追加（あれば）
        if let frequencyCategory = getFrequencyCategory() {
            categories.append(frequencyCategory)
        }

        // デフォルトカテゴリーを追加（frequency を除く）
        let defaultCategories = getDefaultCategories().filter { category in
            category.id != EmojiCategoryType.frequency.rawValue
        }
        categories.append(contentsOf: defaultCategories)

        return categories
    }
}
