//
//  File.swift
//
//
//  Created by Kanghoon Oh on 2022/12/19.
//

import Foundation
import PackagePlugin

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

@main
struct KarrotSwiftFormatPlugin {

  private func performCommand(
    context: PerformCommandContext,
    inputPaths: [String],
    arguments: [String]
  ) throws {
    var argumentExtractor = ArgumentExtractor(arguments)

    let excludedPaths = argumentExtractor.extractOption(named: "exclude")
    let inputPaths = inputPaths.filter { path in
      !excludedPaths.contains(where: { excludedPath in
        path.hasSuffix(excludedPath)
      })
    }

    let launchPath = try context.tool(named: "KarrotSwiftFormatTool").path.string
    let arguments = inputPaths + [
      "--swift-format-path",
      try context.tool(named: "swiftformat").path.string,
      "--swift-format-cache-path",
      context.pluginWorkDirectory.string + "/swiftformat.cache",
    ] + argumentExtractor.remainingArguments

    let process = Process()
    process.launchPath = launchPath
    process.arguments = arguments
    try process.run()
    process.waitUntilExit()

    switch process.terminationStatus {
    case EXIT_SUCCESS:
      break

    case EXIT_FAILURE:
      throw PerformCommandError.formatFailure

    default:
      throw PerformCommandError.unknown(code: process.terminationStatus)
    }
  }
}

extension KarrotSwiftFormatPlugin: CommandPlugin {

  func performCommand(
    context: PluginContext,
    arguments: [String]
  ) async throws {
    var argumentExtractor = ArgumentExtractor(arguments)

    let inputTargets = argumentExtractor.extractOption(named: "target")
    var inputPaths = argumentExtractor.extractOption(named: "paths")

    if !inputTargets.isEmpty {
      inputPaths += try context.package.targets(named: inputTargets).map { $0.directory.string }
    } else if inputPaths.isEmpty {
      inputPaths = try self.inputPaths(for: context.package)
    }

    let swiftVersion = argumentExtractor.extractOption(named: "swift-version").last
      ?? "\(context.package.toolsVersion.major).\(context.package.toolsVersion.minor)"

    let arguments = [
      "--swift-version",
      swiftVersion,
    ] + argumentExtractor.remainingArguments

    try performCommand(
      context: context,
      inputPaths: inputPaths,
      arguments: arguments
    )
  }

  private func inputPaths(for package: Package) throws -> [String] {
    let packageDirectoryContents = try FileManager.default.contentsOfDirectory(
      at: URL(fileURLWithPath: package.directory.string),
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    )

    let subdirectories = packageDirectoryContents.filter { $0.hasDirectoryPath }
    let rootSwiftFiles = packageDirectoryContents.filter { $0.pathExtension.hasSuffix("swift") }
    return (subdirectories + rootSwiftFiles).map { $0.path }
  }
}

#if canImport(XcodeProjectPlugin)
extension KarrotSwiftFormatPlugin: XcodeCommandPlugin {

  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    var argumentExtractor = ArgumentExtractor(arguments)

    let inputTargetNames = Set(argumentExtractor.extractOption(named: "target"))
    let inputPaths = context.xcodeProject.targets.lazy
      .filter { inputTargetNames.contains($0.displayName) }
      .flatMap { $0.inputFiles }
      .map { $0.path.string }
      .filter { $0.hasSuffix(".swift") }

    try performCommand(
      context: context,
      inputPaths: Array(inputPaths),
      arguments: argumentExtractor.remainingArguments
    )
  }
}
#endif
