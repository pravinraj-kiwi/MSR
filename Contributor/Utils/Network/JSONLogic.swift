//
//  JSONLogic.swift
//  Contributor
//
//  Created by John Martin on 1/6/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import Foundation
import os

func evaluateJSONLogicTest(tests: Any, data: [String: AnyHashable]) -> Bool {
  return evaluate(tests: tests, data: data) as! Bool
}

fileprivate func evaluate(tests: Any, data: [String: AnyHashable]) -> Any? {
  if let tests = tests as? [String:[Any]] {
    let op = tests.keys.first!
    
    if op == "var" {
      let key = (tests[op] as! [String])[0]
      return data[key]
    }
    
    let values = tests[op]
    var evaluatedValues: [Any?] = []
    for value in values! {
      let evaluatedValue = evaluate(tests: value, data: data)
      evaluatedValues.append(evaluatedValue)
    }

    switch op {
    
    case "==":
      switch evaluatedValues[0] {
      case let a as Int:
        guard let b = evaluatedValues[1] as? Int else {
          os_log("Failed type conversion to Int for ==", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a == b
      case let a as String:
        guard let b = evaluatedValues[1] as? String else {
          os_log("Failed type conversion to String for ==", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a == b
      case let aString as [String]:
        guard let bString = evaluatedValues[1] as? String else {
        os_log("Failed type conversion to [String] for ==", log: OSLog.logicEngine, type: .error)
        return false
      }
      return aString == [bString]
      default:
        os_log("Failed type conversion for == or first value missing", log: OSLog.logicEngine, type: .error)
        return false
      }

    case "!=":
      switch evaluatedValues[0] {
      case let a as Int:
        guard let b = evaluatedValues[1] as? Int else {
          os_log("Failed type conversion to Int for !=", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a != b
      case let a as String:
        guard let b = evaluatedValues[1] as? String else {
          os_log("Failed conversion to String for !=", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a != b
      default:
        os_log("Failed type conversion for != or first value missing", log: OSLog.logicEngine, type: .error)
        return false
      }

    case ">":
      switch evaluatedValues[0] {
      case let a as Int:
        guard let b = evaluatedValues[1] as? Int else {
          os_log("Failed type conversion to Int for >", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a > b
      default:
        os_log("Failed type conversion for > or first value missing", log: OSLog.logicEngine, type: .error)
        return false
      }

    case "<":
      switch evaluatedValues[0] {
      case let a as Int:
        guard let b = evaluatedValues[1] as? Int else {
          os_log("Failed type conversion to Int for <", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a < b
      default:
        os_log("Failed type conversion for < or first value missing", log: OSLog.logicEngine, type: .error)
        return false
      }

    case ">=":
      switch evaluatedValues[0] {
      case let a as Int:
        guard let b = evaluatedValues[1] as? Int else {
          os_log("Failed conversion to Int for >=", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a >= b
      default:
        os_log("Failed type conversion for >= or first value missing", log: OSLog.logicEngine, type: .error)
        return false
      }
      
    case "<=":
      switch evaluatedValues[0] {
      case let a as Int:
        guard let b = evaluatedValues[1] as? Int else {
          os_log("Failed type conversion to Int for <=", log: OSLog.logicEngine, type: .error)
          return false
        }
        return a <= b
      default:
        os_log("Failed type conversion for <= or first value missing", log: OSLog.logicEngine, type: .error)
        return false
      }

    case "and":
      for v in evaluatedValues {
        guard let v = v as? Bool else {
          os_log("Failed type conversion to Bool for and", log: OSLog.logicEngine, type: .error)
          return false
        }
        
        if !v {
          return false
        }
      }
      return true

    case "or":
      for v in evaluatedValues {
        guard let v = v as? Bool else {
          os_log("Failed type conversion to Bool for or", log: OSLog.logicEngine, type: .error)
          return false
        }
        
        if v {
          return true
        }
      }
      return false

    case "in":
      switch evaluatedValues[0] {
      case let a as Int:
        guard let b = evaluatedValues[1] as? [Int] else {
          os_log("Failed type conversion to [Int] for in", log: OSLog.logicEngine, type: .error)
          return false
        }
        return b.contains(a)
      case let a as String:
        guard let b = evaluatedValues[1] as? [String] else {
          os_log("Failed type conversion to [String] for in", log: OSLog.logicEngine, type: .error)
          return false
        }
        return b.contains(a)
      default:
        os_log("Failed type conversion for in or first value missing", log: OSLog.logicEngine, type: .error)
        return false
      }
    
    case "!":
      switch evaluatedValues[0] {
      case let a as Bool:
        return !a
      default:
        os_log("Failed type conversion for ! or value missing", log: OSLog.logicEngine, type: .error)
        return false
      }

    default:
      return false
    }    
  }
  else {
    return tests
  }
}
