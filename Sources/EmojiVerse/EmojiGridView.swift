import NukeUI
import SwiftUI

/// 絵文字をグリッド形式で表示するビュー
struct EmojiGridView: View {
  let category: EmojiCategory
  let onEmojiSelected: (EmojiItem) -> Void

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 8)
  private let emojiSize: CGFloat = 32

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(category.emojis) { emoji in
          EmojiItemView(emoji: emoji, size: emojiSize)
            .onTapGesture {
              onEmojiSelected(emoji)
            }
        }
      }
      .padding()
    }
    // カテゴリーごとに独立した ScrollView インスタンスを作成
    // これによりスクロール位置が個別に保持される
    .id(category.id)
  }
}

/// 個別の絵文字アイテムを表示するビュー
private struct EmojiItemView: View {
  let emoji: EmojiItem
  let size: CGFloat

  var body: some View {
    // customImageUrl が設定されている場合は画像として表示（Unicode 絵文字のカスタム画像対応）
    if let customUrl = emoji.customImageUrl {
      LazyImage(url: customUrl) { state in
        if let image = state.image {
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
        } else if state.isLoading {
          ProgressView()
            .frame(width: size, height: size)
        } else {
          // 画像読み込み失敗時は元のタイプに応じた表示にフォールバック
          fallbackView
        }
      }
      .frame(width: size + 8, height: size + 8)
    } else {
      // customImageUrl がない場合は通常の表示
      defaultView
    }
  }

  /// デフォルトの表示（タイプに応じた表示）
  @ViewBuilder
  private var defaultView: some View {
    switch emoji.type {
    case .unicode(let text):
      Text(text)
        .font(.system(size: size))
        .frame(width: size + 8, height: size + 8)

    case .url(let url):
      LazyImage(url: url) { state in
        if let image = state.image {
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
        } else if state.isLoading {
          ProgressView()
            .frame(width: size, height: size)
        } else {
          Rectangle()
            .fill(.secondary.opacity(0.25))
            .frame(width: size, height: size)
        }
      }
      .frame(width: size + 8, height: size + 8)

    case .image(let uiImage):
      Image(uiImage: uiImage)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: size, height: size)
        .frame(width: size + 8, height: size + 8)
    }
  }

  /// フォールバック表示（カスタム画像読み込み失敗時）
  @ViewBuilder
  private var fallbackView: some View {
    switch emoji.type {
    case .unicode(let text):
      Text(text)
        .font(.system(size: size))
        .frame(width: size, height: size)
    default:
      Rectangle()
        .fill(.secondary.opacity(0.25))
        .frame(width: size, height: size)
    }
  }
}
