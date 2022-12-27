//
//  PerformCommandContext.swift
//
//
//  Created by Kanghoon Oh on 2022/12/20.
//

import PackagePlugin

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

protocol PerformCommandContext {
  var pluginWorkDirectory: Path { get }
  func tool(named name: String) throws -> PluginContext.Tool
}

extension PluginContext: PerformCommandContext {}

#if canImport(XcodeProjectPlugin)
extension XcodePluginContext: PerformCommandContext {}
#endif
