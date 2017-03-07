//
//  EntryTest.swift
//  CDAKit
//
//  Created by Eric Whitley on 12/14/15.
//  Copyright © 2015 Eric Whitley. All rights reserved.
//

import XCTest
@testable import CDAKit


class EntryTest: XCTestCase {
  
  var entry: CDAKEntry!
  
  override func setUp() {
      super.setUp()

    entry = CDAKEntry()
    var codes = CDAKCodedEntries()
    let entries: [String:[String]] = [
    "SNOMED-CT" : ["1234", "5678", "AABB"],
    "LOINC" : ["CCDD", "EEFF"],
    "ICD-9-CM" : ["GGHH"]
    ]
    for (system, code_list) in entries {
      for code in code_list {
        codes.addCodes(system, code: code)
      }
    }
    
    entry.codes = codes
  }
  
  override func tearDown() {
      super.tearDown()
  }
  
  func test_preferred_code() {

    var preferred_code = entry.preferred_code(["ICD-9-CM"])
    XCTAssertEqual("ICD-9-CM", preferred_code!.codeSystem)
    XCTAssertEqual("GGHH", preferred_code!.code)
    
    preferred_code = entry.preferred_code(["LOINC"])
    XCTAssertEqual("LOINC", preferred_code!.codeSystem)
    XCTAssert(["CCDD", "EEFF"].contains(preferred_code!.code))

    //sample from the view helper test case
    let fields: [String:Any?] = [
      "description" : "bacon > cheese",
      "time" : 1234,
      "codes" : ["CPT" : ["1234"]]
    ]
    let _ = CDAKEntry(event: fields)
  }

  func test_translation_codes() {

    let translation_codes = entry.translation_codes(["ICD-9-CM"])
    print("test_translation_codes -> translation_codes: \(translation_codes)")
    XCTAssertEqual(5, translation_codes.numberOfDistinctCodes)
    XCTAssert(translation_codes.containsCode(withCodeSystem: "LOINC", andCode: "CCDD"))
    XCTAssert(!translation_codes.containsCode(withCodeSystem: "ICD-9-CM", andCode: "GGHH"))
    
  }

  func test_is_usable() {
    let entry = CDAKEntry()
    entry.time = 1270598400
    entry.add_code("314443004", code_system: "SNOMED-CT")
    XCTAssert(entry.usable())
  }

  func test_from_event_hash() {
    
    let hash: [String:Any?] = [
      "code" : 123, "code_set" : "RxNorm",
      "value" : 50, "unit" : "mm",
      "description" : "Test",
      "specifics" : "Specific",
      "status" : "active"
    ]
    
    
    let entry = CDAKEntry(from_hash: hash)
    XCTAssertEqual([String(describing: hash["code"]!!)], [entry.codes["RxNorm"]!.first!.code])
    XCTAssertEqual(String(describing: hash["value"]!!), (entry.values.first as! CDAKPhysicalQuantityResultValue).scalar)
    XCTAssertEqual(String(describing: hash["unit"]!!), (entry.values.first as! CDAKPhysicalQuantityResultValue).units)
    XCTAssertEqual(String(describing: hash["specifics"]!!), entry.specifics)
    XCTAssertEqual(String(describing: hash["status"]!!), entry.status)
  }

  func test_unusable_without_time() {
    let entry = CDAKEntry()
    entry.add_code("314443004", code_system: "SNOMED-CT")
    XCTAssert(!entry.usable())
  }

  func test_unusable_without_code() {
    let entry = CDAKEntry()
    entry.time = 1270598400
    XCTAssert(!entry.usable())
  }

  func test_is_in_code_set() {
    let entry = CDAKEntry()
    entry.add_code("854935", code_system: "RxNorm")
    entry.add_code("44556699", code_system: "RxNorm")
    entry.add_code("1245", code_system: "Junk")
    var some_codes = CDAKCodedEntries()
    some_codes.addCodes("RxNorm", code: "854935")
    some_codes.addCodes("RxNorm", code: "5440")
    some_codes.addCodes("SNOMED-CT", code: "24601")
    XCTAssert(entry.is_in_code_set([some_codes]))
  }

  func test_is_not_in_code_set() {
    let entry = CDAKEntry()
    entry.add_code("44556699", code_system: "RxNorm")
    entry.add_code("1245", code_system: "Junk")
    var some_codes = CDAKCodedEntries()
    some_codes.addCodes("RxNorm", code: "854935")
    some_codes.addCodes("RxNorm", code: "5440")
    some_codes.addCodes("SNOMED-CT", code: "24601")
    XCTAssert(!entry.is_in_code_set([some_codes]))
  }

  func test_equality() {
    let entry1 = CDAKEntry()
    entry1.add_code("44556699", code_system: "RxNorm")
    entry1.time = 1270598400
    
    let entry2 = CDAKEntry()
    entry2.add_code("44556699", code_system: "RxNorm")
    entry2.time = 1270598400
    
    let entry3 = CDAKEntry()
    entry3.add_code("44556699", code_system: "RxNorm")
    entry3.time = 1270598401
    
    XCTAssertEqual(entry1, entry2)
    XCTAssertEqual(entry2, entry1)
    XCTAssert(entry2 != entry3)
    XCTAssert(entry1 != entry3)
  }

  func test_identifier_id() {
    let entry = CDAKEntry()
    XCTAssertEqual(entry.id, entry.identifier as? String)
  }

  func test_identifier_cda_identifier() {
    let identifier = CDAKCDAIdentifier(root: "1.2.3.4")
    entry.cda_identifier = identifier
    XCTAssertEqual(identifier, entry.identifier as? CDAKCDAIdentifier)
  }

  
}
