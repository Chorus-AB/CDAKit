//
//  BasicXPathTest.swift
//  CDAKit
//
//  Created by Eric Whitley on 1/11/16.
//  Copyright © 2016 Eric Whitley. All rights reserved.
//

import XCTest
@testable import CDAKit

import Mustache

class BasicXPathTest: XCTestCase {
    
  override func setUp() {
      super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
  }
  
  func testLoadingFile() {
    let _ = TestHelpers.fileHelpers.load_xml_string_from_file("Rosa.c32")
  }

  func testC32RecordImport() {
    let c32Doc = TestHelpers.fileHelpers.load_xml_string_from_file("Rosa.c32")
    
    do {
      let _ = try CDAKImport_BulkRecordImporter.importRecord(c32Doc)
    }
    catch {
      XCTFail()
    }
  }

  func testImportWithTypeDetection_CCDA() {
    let doc = TestHelpers.fileHelpers.load_xml_string_from_file("sample_ccda")

    do {
      let _ = try CDAKImport_BulkRecordImporter.importRecord(doc)
    }
    catch {
      XCTFail()
    }

  }

  func testImportWithTypeDetection_C32() {
    let doc = TestHelpers.fileHelpers.load_xml_string_from_file("NISTExampleC32")
    do {
      let _ = try CDAKImport_BulkRecordImporter.importRecord(doc)
    }
    catch {
      XCTFail()
    }
  }

  func testImportWithExternalRecord_GithubCCD() {
    let doc = TestHelpers.fileHelpers.load_xml_string_from_file("Vitera_CCDA_SMART_Sample")
    do {
      let _ = try CDAKImport_BulkRecordImporter.importRecord(doc)
    }
    catch {
      XCTFail()
    }
  }

  func testImportWithExternalRecord_HealthKitCDA() {
    let doc = TestHelpers.fileHelpers.load_xml_string_from_file("export_cda")
    do {
      let _ = try CDAKImport_BulkRecordImporter.importRecord(doc)
    }
    catch {
      XCTFail()
    }
  }
  
  
  func testRecordXMLInitializer_VALID() {
    
    let doc = TestHelpers.fileHelpers.load_xml_string_from_file("Vitera_CCDA_SMART_Sample")
    do {
      let _ = try CDAKRecord.init(fromXML: doc)
    } catch {
      XCTFail()
      
    }
  }
  

  func testRecordXMLInitializer_NOT_VALID() {
    
    let doc = "<?xml version=\"1.0\"?>NOPE"
    do {
      let _ = try CDAKRecord.init(fromXML: doc)
      XCTFail() // we shouldn't get here
    }
    catch {
    }
    
  }

  
  func testExport() {

    let doc = TestHelpers.fileHelpers.load_xml_string_from_file("Vitera_CCDA_SMART_Sample")
    do {
      let record = try CDAKImport_BulkRecordImporter.importRecord(doc)
      let _ = record.export(inFormat: .ccda)
    }
    catch {
      XCTFail()
    }
  }
  
}
