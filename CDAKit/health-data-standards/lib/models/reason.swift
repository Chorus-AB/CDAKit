//
//  reason.swift
//  
//
//  Created by Eric Whitley on 1/5/16.
//
//

import Foundation
import Mustache

/** Reason */
open class CDAKReason: CDAKEntry {

  // MARK: Standard properties
  ///Debugging description
  override open var description: String {
    return "CDAKReason => description: \(item_description), codes: \(codes)"
  }
  
}