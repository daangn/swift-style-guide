//
//  KarrotSwiftFormatTool.swift
//
//
//  Created by Kanghoon Oh on 2022/12/19.
//

import ArgumentParser
import Foundation

@main
struct KarrotSwiftFormatTool: ParsableCommand {

  @Argument(help: "The directories to format")
  var directories: [String]

  @Option(help: "The absolute path to a SwiftFormat binary")
  var swiftFormatPath: String

  @Option(help: "The absolute path to the swiftformat file")
  var swiftFormatConfig = Bundle.module.path(forResource: "karrot", ofType: "swiftformat")!

  @Option(help: "The absolute path to use for SwiftFormat's cache")
  var swiftFormatCachePath: String?

  @Option(help: "The swift version")
  var swiftVersion: String?

  private lazy var swiftFormat: Process = {
    var arguments = directories + [
      "--config", swiftFormatConfig,
    ]

    if let swiftFormatCachePath {
      arguments += ["--cache", swiftFormatCachePath]
    }

    if let swiftVersion {
      arguments += ["--swiftversion", swiftVersion]
    }

    let swiftFormat = Process()
    swiftFormat.launchPath = swiftFormatPath
    swiftFormat.arguments = arguments
    return swiftFormat
  }()

  mutating func run() throws {
    try swiftFormat.run()
    swiftFormat.waitUntilExit()

    if swiftFormat.terminationStatus != EXIT_SUCCESS {
      throw ExitCode(swiftFormat.terminationStatus)
    }
  }
}
