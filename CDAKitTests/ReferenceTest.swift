//
//  CDAKReferenceTest.swift
//  CDAKit
//
//  Created by Eric Whitley on 12/9/15.
//  Copyright © 2015 Eric Whitley. All rights reserved.
//

import XCTest
@testable import CDAKit


class CDAKReferenceTest: XCTestCase {
    
  override func setUp() {
      super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
  }
  
  func test_references() {
    let r = CDAKRecord()
    
    let c1 = CDAKCondition()
    let c2 = CDAKCondition()

    r.conditions.append(c1)
    r.conditions.append(c2)
    
    c1.add_reference(c2, type: "FLFS")
    let refs = c1.references.filter({$0.type == "FLFS"})
    
    XCTAssertEqual(1, refs.count, "expected 1 reference")

//    let entries = r.entries
//    let x = refs[0].resolve_reference()
//    let y = ""
    
    XCTAssertEqual(c2 as CDAKEntry, refs[0].resolve_reference()!)
    
  }
    
}
