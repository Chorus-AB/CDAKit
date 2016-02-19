//
//  result_value.swift
//  CDAKit
//
//  Created by Eric Whitley on 11/30/15.
//  Copyright © 2015 Eric Whitley. All rights reserved.
//

import Foundation

/**
Result Value
*/
public class CDAKResultValue: NSObject, CDAKThingWithTimes {

  // MARK: CDA properties
  ///Ad-hoc attributes
  public var attributes: [String:String] = [String:String]()

  ///time
  public var time: Double?
  //this is not originally in the model, but found instances where dynamic properties
  // were being referfenced for this - see protocol ThingWithTimes
  ///start time
  public var start_time: Double?
  ///end time
  public var end_time: Double?
  
  // MARK: Standard properties
  ///Debugging description
  override public var description: String {
    return "\(self.dynamicType) => attributes: \(attributes), time: \(time), start_time: \(start_time), end_time: \(end_time)"
  }
  
}

// MARK: - JSON Generation
extension CDAKResultValue: CDAKJSONExportable {
  ///Dictionary for JSON data
  public var jsonDict: [String: AnyObject] {
    var dict: [String: AnyObject] = [:]
    
    if let time = time {
      dict["time"] = time
    }
    if let start_time = start_time {
      dict["start_time"] = start_time
    }
    if let end_time = end_time {
      dict["end_time"] = end_time
    }
    
    return dict
  }
}

