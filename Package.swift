// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KarrotSwift",
  platforms: [.macOS(.v10_13)],
  products: [
    .plugin(name: "KarrotSwiftFormat", targets: ["KarrotSwiftFormat"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
  ],
  targets: [
    .plugin(
      name: "KarrotSwiftFormat",
      capability: .command(
        intent: .custom(
          verb: "format",
          description: "Format Swift Sources"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "Format Swift Sources"),
        ]
      ),
      dependencies: [
        "KarrotSwiftFormatTool",
        "SwiftFormat",
      ]
    ),
    .executableTarget(
      name: "KarrotSwiftFormatTool",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      resources: [
        .process("karrot.swiftformat"),
      ]
    ),
    .binaryTarget(
      name: "SwiftFormat",
      url: "https://github.com/calda/SwiftFormat/releases/download/0.51-beta-6/SwiftFormat.artifactbundle.zip",
      checksum: "8583456d892c99f970787b4ed756a7e0c83a0d9645e923bb4dae10d581c59bc3"
    ),
  ]
)
