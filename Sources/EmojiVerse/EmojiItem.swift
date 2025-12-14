import Foundation
import SwiftUI

/// 絵文字アイテムの種類
enum EmojiItemType {
  /// ネイティブの Unicode 絵文字
  case unicode(String)
  /// 外部 URL から読み込む画像
  case url(URL)
  /// ローカルの UIImage
  case image(UIImage)
}

/// 絵文字ピッカーで使用する絵文字アイテム
struct EmojiItem: Identifiable, Equatable {
  let id: String
  let type: EmojiItemType
  let keywords: [String]
  /// Unicode 絵文字のカスタム画像 URL（オプショナル）
  let customImageUrl: URL?

  init(id: String, type: EmojiItemType, keywords: [String] = [], customImageUrl: URL? = nil) {
    self.id = id
    self.type = type
    self.keywords = keywords
    self.customImageUrl = customImageUrl
  }

  /// Unicode 絵文字を作成
  static func unicode(_ emoji: String, keywords: [String] = [], customImageUrl: URL? = nil)
    -> EmojiItem
  {
    EmojiItem(id: emoji, type: .unicode(emoji), keywords: keywords, customImageUrl: customImageUrl)
  }

  /// URL から読み込む絵文字を作成
  static func url(id: String, url: URL, keywords: [String] = []) -> EmojiItem {
    EmojiItem(id: id, type: .url(url), keywords: keywords)
  }

  /// UIImage から絵文字を作成
  static func image(id: String, image: UIImage, keywords: [String] = []) -> EmojiItem {
    EmojiItem(id: id, type: .image(image), keywords: keywords)
  }

  static func == (lhs: EmojiItem, rhs: EmojiItem) -> Bool {
    lhs.id == rhs.id
  }
}
