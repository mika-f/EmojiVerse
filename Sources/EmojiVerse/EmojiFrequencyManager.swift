import Foundation

/// 絵文字の使用頻度を管理するクラス
class EmojiFrequencyManager {
  static let shared = EmojiFrequencyManager()

  private let userDefaults = UserDefaults.standard
  private let frequencyKey = "emoji_frequency_v2"  // v2: カスタム絵文字対応
  private let maxFrequencyCount = 30  // 最大保存数

  /// 絵文字の種類
  enum EmojiType: String, Codable {
    case unicode
    case url
  }

  /// 使用履歴アイテム
  struct FrequencyItem: Codable {
    let type: EmojiType
    let value: String  // unicode の場合は絵文字文字列、url の場合は URL 文字列
    let id: String  // 識別子（unicode の場合は絵文字文字列、url の場合は shortcode など）
    let timestamp: Date
    var count: Int

    init(type: EmojiType, value: String, id: String) {
      self.type = type
      self.value = value
      self.id = id
      self.timestamp = Date()
      self.count = 1
    }

    // 後方互換性のため、古い形式もサポート
    init(emoji: String) {
      self.type = .unicode
      self.value = emoji
      self.id = emoji
      self.timestamp = Date()
      self.count = 1
    }
  }

  private init() {}

  /// Unicode 絵文字を使用履歴に追加
  func recordUsage(emoji: String) {
    recordUsage(type: .unicode, value: emoji, id: emoji)
  }

  /// カスタム絵文字を使用履歴に追加
  func recordUsage(customEmojiId: String, url: String) {
    recordUsage(type: .url, value: url, id: customEmojiId)
  }

  /// 絵文字を使用履歴に追加（内部メソッド）
  private func recordUsage(type: EmojiType, value: String, id: String) {
    var items = getFrequencyItems()

    // 既存のアイテムを検索
    if let index = items.firstIndex(where: { $0.id == id }) {
      // 既存の場合、カウントを増やしてタイムスタンプを更新
      var item = items[index]
      item.count += 1
      items.remove(at: index)
      items.insert(
        FrequencyItem(type: type, value: value, id: id),
        at: 0
      )
    } else {
      // 新規の場合、先頭に追加
      items.insert(FrequencyItem(type: type, value: value, id: id), at: 0)
    }

    // 最大数を超えた場合、古いものを削除
    if items.count > maxFrequencyCount {
      items = Array(items.prefix(maxFrequencyCount))
    }

    // 保存
    saveFrequencyItems(items)
  }

  /// 最近使用した絵文字のアイテムを取得（使用順）
  func getRecentEmojiItems() -> [FrequencyItem] {
    return getFrequencyItems()
  }

  /// 最近使用した絵文字のリストを取得（使用順、後方互換性のため）
  func getRecentEmojis() -> [String] {
    let items = getFrequencyItems()
    return items.compactMap { item in
      item.type == .unicode ? item.value : nil
    }
  }

  /// 使用頻度の高い絵文字のリストを取得（頻度順）
  func getFrequentEmojis() -> [String] {
    var items = getFrequencyItems()
    items.sort { $0.count > $1.count }
    return items.compactMap { item in
      item.type == .unicode ? item.value : nil
    }
  }

  /// 履歴をクリア
  func clearHistory() {
    userDefaults.removeObject(forKey: frequencyKey)
  }

  // MARK: - Private Methods

  private func getFrequencyItems() -> [FrequencyItem] {
    guard let data = userDefaults.data(forKey: frequencyKey),
      let items = try? JSONDecoder().decode([FrequencyItem].self, from: data)
    else {
      return []
    }
    return items
  }

  private func saveFrequencyItems(_ items: [FrequencyItem]) {
    if let data = try? JSONEncoder().encode(items) {
      userDefaults.set(data, forKey: frequencyKey)
    }
  }
}
