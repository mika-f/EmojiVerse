import Foundation
import SwiftUI

/// 絵文字のカテゴリー
public struct EmojiCategory: Identifiable, Equatable {
  public let id: String
  public let title: String
  public let icon: String  // SF Symbol name
  public let emojis: [EmojiItem]

  public init(id: String, title: String, icon: String, emojis: [EmojiItem]) {
    self.id = id
    self.title = title
    self.icon = icon
    self.emojis = emojis
  }

  public static func == (lhs: EmojiCategory, rhs: EmojiCategory) -> Bool {
    lhs.id == rhs.id
  }
}

/// 利用可能な絵文字カテゴリーの種類
public enum EmojiCategoryType: String, CaseIterable {
  case frequency = "frequency"
  case smileysAndPeople = "smileys_and_people"
  case animalsAndNature = "animals_and_nature"
  case foodAndDrink = "food_and_drink"
  case activity = "activity"
  case travelAndPlaces = "travel_and_places"
  case objects = "objects"
  case symbols = "symbols"
  case flags = "flags"

  var title: String {
    switch self {
    case .frequency:
      return "最近使った絵文字"
    case .smileysAndPeople:
      return "スマイリーと人々"
    case .animalsAndNature:
      return "動物と自然"
    case .foodAndDrink:
      return "食べ物と飲み物"
    case .activity:
      return "アクティビティ"
    case .travelAndPlaces:
      return "旅行と場所"
    case .objects:
      return "物"
    case .symbols:
      return "記号"
    case .flags:
      return "旗"
    }
  }

  var icon: String {
    switch self {
    case .frequency:
      return "clock.fill"
    case .smileysAndPeople:
      return "face.smiling"
    case .animalsAndNature:
      return "pawprint.fill"
    case .foodAndDrink:
      return "fork.knife"
    case .activity:
      return "sportscourt.fill"
    case .travelAndPlaces:
      return "airplane"
    case .objects:
      return "lightbulb.fill"
    case .symbols:
      return "heart.fill"
    case .flags:
      return "flag.fill"
    }
  }
}
