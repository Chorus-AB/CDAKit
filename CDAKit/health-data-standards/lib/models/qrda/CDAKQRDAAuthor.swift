//
//  CDAKQRDAAuthor.swift
//  CDAKit
//
//  Created by Eric Whitley on 2/16/16.
//  Copyright © 2016 Eric Whitley. All rights reserved.
//

import Foundation
import Mustache

open class CDAKQRDAAuthor: CDAKThingWithCodes {
  open var time = Date()
  open var ids: [CDAKCDAIdentifier] = []
  open var addresses: [CDAKAddress] = []
  open var telecoms: [CDAKTelecom] = []
  open var person: CDAKPerson?
  open var device: CDAKQRDADevice?
  open var organization: CDAKOrganization?

  public var codes:CDAKCodedEntries = CDAKCodedEntries();

  public init() { }
}

extension CDAKQRDAAuthor: CustomStringConvertible {
  public var description: String {
    return "CDAKQRDAAuthor => time:\(time), ids:\(ids), addresses:\(addresses), telecoms:\(telecoms), person:\(person), device:\(device), organization: \(organization), codes: \(codes)"
  }
}

extension CDAKQRDAAuthor: MustacheBoxable {
  var boxedValues: [String:MustacheBox] {
    return [
      "time" :  Box(time.timeIntervalSince1970),
      "ids" :  Box(ids),
      "addresses" :  Box(addresses),
      "telecoms" :  Box(telecoms),
      "person" :  Box(person),
      "device" :  Box(device),
      "organization" :  Box(organization),
      "codes" :  Box(codes),
      "preferred_code" :  Box(codes.first)
    ]
  }
  
  public var mustacheBox: MustacheBox {
    return Box(boxedValues)
  }
}

extension CDAKQRDAAuthor: CDAKJSONExportable {
  public var jsonDict: [String: AnyObject] {
    var dict: [String: AnyObject] = [:]
    dict["time"] = time.description as AnyObject?
    if ids.count > 0 {
      dict["ids"] = ids.map({$0.jsonDict}) as AnyObject?
    }
    if addresses.count > 0 {
      dict["addresses"] = addresses.map({$0.jsonDict}) as AnyObject?
    }
    if telecoms.count > 0 {
      dict["telecoms"] = telecoms.map({$0.jsonDict}) as AnyObject?
    }
    if let person = person {
      dict["person"] = person.jsonDict as AnyObject?
    }
    if let device = device {
      dict["device"] = device.jsonDict as AnyObject?
    }
    if let organization = organization {
      dict["organization"] = organization.jsonDict as AnyObject?
    }
    return dict
  }
}
