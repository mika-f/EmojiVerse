import Foundation

extension String {
  /// Unicode 絵文字のコードポイントを16進数文字列として取得
  /// 例: "🐶" -> "1f436"
  var unicodeCodepoint: String? {
    guard let scalar = self.unicodeScalars.first else {
      return nil
    }
    return String(format: "%x", scalar.value)
  }

  /// 複数のUnicode絵文字のコードポイントを連結して取得
  /// 例: "👨‍👩‍👧" -> "1f468-200d-1f469-200d-1f467"
  var unicodeCodepoints: String {
    return self.unicodeScalars
      .map { String(format: "%x", $0.value) }
      .joined(separator: "-")
  }
}
