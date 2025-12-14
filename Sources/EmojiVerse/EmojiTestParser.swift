import Foundation

/// emoji-test.txt ファイルをパースするクラス
struct EmojiTestParser {
  /// パースされた絵文字データ
  struct ParsedEmoji {
    let codePoints: String
    let emoji: String
    let name: String
    let group: String
    let subgroup: String
  }

  /// emoji-test.txt ファイルをパースする
  static func parse() -> [String: [ParsedEmoji]] {
    guard let path = Bundle.main.path(forResource: "emoji-test", ofType: "txt"),
      let content = try? String(contentsOfFile: path, encoding: .utf8)
    else {
      print("Warning: emoji-test.txt not found, using empty data")
      return [:]
    }

    var result: [String: [ParsedEmoji]] = [:]
    var currentGroup = ""
    var currentSubgroup = ""

    let lines = content.components(separatedBy: .newlines)

    for line in lines {
      let trimmedLine = line.trimmingCharacters(in: .whitespaces)

      // 空行またはコメント行をスキップ（グループ・サブグループ定義を除く）
      if trimmedLine.isEmpty {
        continue
      }

      // グループの検出
      if trimmedLine.hasPrefix("# group:") {
        currentGroup =
          trimmedLine
          .replacingOccurrences(of: "# group:", with: "")
          .trimmingCharacters(in: .whitespaces)
        continue
      }

      // サブグループの検出
      if trimmedLine.hasPrefix("# subgroup:") {
        currentSubgroup =
          trimmedLine
          .replacingOccurrences(of: "# subgroup:", with: "")
          .trimmingCharacters(in: .whitespaces)
        continue
      }

      // コメント行をスキップ
      if trimmedLine.hasPrefix("#") {
        continue
      }

      // 絵文字データ行のパース
      // フォーマット: コードポイント ; ステータス # 絵文字 バージョン 名前
      guard trimmedLine.contains(";"), trimmedLine.contains("#") else {
        continue
      }

      let parts = trimmedLine.components(separatedBy: ";")
      guard parts.count >= 2 else {
        continue
      }

      let codePoints = parts[0].trimmingCharacters(in: .whitespaces)
      let statusAndComment = parts[1]

      // ステータスとコメント部分を分割
      let statusParts = statusAndComment.components(separatedBy: "#")
      guard statusParts.count >= 2 else {
        continue
      }

      let status = statusParts[0].trimmingCharacters(in: .whitespaces)

      // fully-qualified のみを使用
      guard status == "fully-qualified" else {
        continue
      }

      let comment = statusParts[1].trimmingCharacters(in: .whitespaces)

      // コメントから絵文字と名前を抽出
      // フォーマット: 絵文字 バージョン 名前
      let commentParts = comment.components(separatedBy: " ")
      guard commentParts.count >= 3 else {
        continue
      }

      let emoji = commentParts[0]
      // バージョン（E1.0など）をスキップして名前を取得
      let name = commentParts.dropFirst(2).joined(separator: " ")

      let parsedEmoji = ParsedEmoji(
        codePoints: codePoints,
        emoji: emoji,
        name: name,
        group: currentGroup,
        subgroup: currentSubgroup
      )

      if result[currentGroup] == nil {
        result[currentGroup] = []
      }
      result[currentGroup]?.append(parsedEmoji)
    }

    return result
  }

  /// グループ名を EmojiCategoryType にマッピング
  static func mapGroupToCategory(_ group: String) -> String? {
    switch group {
    case "Smileys & Emotion":
      return EmojiCategoryType.smileysAndPeople.rawValue
    case "People & Body":
      return EmojiCategoryType.smileysAndPeople.rawValue
    case "Animals & Nature":
      return EmojiCategoryType.animalsAndNature.rawValue
    case "Food & Drink":
      return EmojiCategoryType.foodAndDrink.rawValue
    case "Activities":
      return EmojiCategoryType.activity.rawValue
    case "Travel & Places":
      return EmojiCategoryType.travelAndPlaces.rawValue
    case "Objects":
      return EmojiCategoryType.objects.rawValue
    case "Symbols":
      return EmojiCategoryType.symbols.rawValue
    case "Flags":
      return EmojiCategoryType.flags.rawValue
    default:
      return nil
    }
  }
}
