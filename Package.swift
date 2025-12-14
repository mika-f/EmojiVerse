// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "EmojiVerse",
  defaultLocalization: "ja",
  platforms: [
    .iOS("17.0"),
    .macOS("14.0"),
  ],
  products: [
    .library(
      name: "EmojiVerse",
      targets: ["EmojiVerse"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/kean/Nuke", .upToNextMajor(from: "12.8.0"))
  ],
  targets: [
    .target(
      name: "EmojiVerse",
      dependencies: [
        .product(name: "NukeUI", package: "Nuke"),
      ],
      resources: [.process("Resources")],
    )
  ]
)
