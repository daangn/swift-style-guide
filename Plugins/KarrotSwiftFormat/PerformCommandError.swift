//
//  PerformCommandError.swift
//  
//
//  Created by Kanghoon Oh on 2022/12/20.
//

import Foundation

enum PerformCommandError: Error {
  case formatFailure
  case unknown(code: Int32)
}
