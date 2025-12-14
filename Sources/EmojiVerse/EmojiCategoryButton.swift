import SwiftUI

/// カテゴリー選択ボタン
struct EmojiCategoryButton: View {
  let category: EmojiCategory
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: category.icon)
          .font(.system(size: 20))
          .foregroundColor(isSelected ? .accentColor : .secondary)
          .frame(width: 32, height: 32)

        if isSelected {
          Rectangle()
            .fill(Color.accentColor)
            .frame(height: 2)
        } else {
          Rectangle()
            .fill(Color.clear)
            .frame(height: 2)
        }
      }
    }
    .buttonStyle(.plain)
  }
}
