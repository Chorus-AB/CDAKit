//
//  CDAKValueAndUnit.swift
//  CDAKit
//
//  Created by Eric Whitley on 2/4/16.
//  Copyright © 2016 Eric Whitley. All rights reserved.
//

import Foundation
import Mustache

public struct CDAKValueAndUnit {
  public var value: Double?
  public var unit: String?

  public init() {}

  public init(value: Double?, unit: String?) {
    self.value = value;
    self.unit = unit;
  }

  public init(value: NSDecimalNumber?, unit: String?) {
    if let value:NSDecimalNumber = value {
      self.value = value.doubleValue;
    }
    self.unit = unit;
  }

}

extension CDAKValueAndUnit: MustacheBoxable {
  // MARK: - Mustache marshalling
  var boxedValues: [String:MustacheBox] {
    var vals : [String:MustacheBox] = [:]
    
    if let unit = unit {
      vals["unit"] = Box(unit)
    }
    if let value = value {
      vals["value"] = Box(value)
    }
    
    return vals
  }
  
  public var mustacheBox: MustacheBox {
    return Box(boxedValues)
  }

}

extension CDAKValueAndUnit: CDAKJSONExportable {
  public var jsonDict: [String: AnyObject] {
    var dict: [String: AnyObject] = [:]
    
    if let value = value {
      dict["value"] = value as AnyObject?
    }
    if let unit = unit {
      dict["unit"] = unit as AnyObject?
    }
    
    return dict
  }
}
