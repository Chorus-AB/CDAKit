//
//  provider_importer.swift
//  CDAKit
//
//  Created by Eric Whitley on 1/12/16.
//  Copyright © 2016 Eric Whitley. All rights reserved.
//

import Foundation
import Fuzi

class CDAKImport_CDA_ProviderImporter {
  
  
  /**
  Extract Healthcare Providers from C32
  
  - parameter doc: It is expected that the root node of this document will have the "cda" namespace registered to "urn:hl7-org:v3"
  - returns: an array of providers found in the document
  */
  class func extract_providers(doc: XMLDocument, patient:CDAKPerson? = nil) -> [CDAKProviderPerformance] {
    
    //FIXME: - go back and re-read / test the original Ruby - this seems odd

    let performers = doc.xpath("//cda:documentationOf/cda:serviceEvent/cda:performer")
    var performances: [CDAKProviderPerformance] = []
    for performer in performers {
      var provider_perf = CDAKImport_CDA_ProviderImporter.extract_provider_data(performer, use_dates: true)
      //this is for QRDA1 only, so I'm not sure we should go down this rabbit hole
      let pp = CDAKProviderPerformance()
      if let start_date = provider_perf["start"] as? Double {
        pp.start_date = start_date
        provider_perf["start"] = nil
      }
      if let end_date = provider_perf["end"] as? Double {
        pp.end_date = end_date
        provider_perf["end"] = nil
      }
      pp.provider = CDAKImport_ProviderImportUtils.find_or_create_provider(provider_perf, patient: patient)
      performances.append(pp)
    }

    return performances
  }
  
  //NOTE: this doesn't return a CDAKProvider in the original Ruby CDAK - it returns a hash of [String:Any]
  // I'm changing it
  //  we need to return start date, end date, and provider data
  //  Instead... I'm going to return a whole new CDAKProvider instead
  //  start, end, provider
  class func extract_provider_data(performer:XMLElement, use_dates:Bool = true, entity_path: String = "./cda:assignedEntity") -> [String:Any] {
    
    var provider_data: [String:Any] = [:]

    if let entity = performer.xpath(entity_path).first {
      
      var cda_idents: [CDAKCDAIdentifier] = []
      
      for cda_ident in entity.xpath("./cda:id") {
        if let ident_root = cda_ident["root"] {
          let ident_extension = cda_ident["extension"]
          cda_idents.append(CDAKCDAIdentifier(root: ident_root, extension_id: ident_extension))
        }
      }
      
      if let name = entity.xpath("./cda:assignedPerson/cda:name").first {
        provider_data["title"]        = extract_data(name, query: "./cda:prefix")
        provider_data["given_name"]   = extract_data(name, query: "./cda:given[1]")
        provider_data["family_name"]  = extract_data(name, query: "./cda:family")
      }
      provider_data["organization"] = CDAKImport_CDA_OrganizationImporter.extract_organization(entity.xpath("./cda:representedOrganization").first)
      provider_data["specialty"]    = extract_data(entity, query: "./cda:code/@code")

      //MARK: FIXME - look at original CDAK code - note how it's performer.xpath(performer...) - ?????
      //let time                 = performer.xpath(performer, "./cda:time")
      if let time = performer.xpath("./cda:time").first {
        if use_dates == true {
          provider_data["start"]        = extract_date(time, query: "./cda:low/@value")
          provider_data["end"]          = extract_date(time, query: "./cda:high/@value")
        }
      }
      
      //# NIST sample C32s use different OID for NPI vs C83, support both
      let npi  = extract_data(entity, query: "./cda:id[@root='2.16.840.1.113883.4.6' or @root='2.16.840.1.113883.3.72.5.2']/@extension")
      provider_data["addresses"] = performer.xpath("./cda:assignedEntity/cda:addr").map { ae in CDAKImport_CDA_LocatableImportUtils.import_address(ae)}
      provider_data["telecoms"] = performer.xpath("./cda:assignedEntity/cda:telecom").map { te in CDAKImport_CDA_LocatableImportUtils.import_telecom(te)}
      
      if CDAKProvider.valid_npi(npi) {
        provider_data["npi"] = npi
      } else {
        print("Invalid NPI '\(npi)' found. Including NPI, but please validate.")
        if npi != "nil" {
          provider_data["npi"] = npi
        }
      }
      provider_data["cda_identifiers"] = cda_idents
      
    }
    
    return provider_data
  }
  
  
  class func extract_date(subject: XMLElement, query: String) -> Double? {
    if let date = extract_data(subject, query: query) {
      return NSDate.dateFromHDSFormattedString(date)?.timeIntervalSince1970
    }
    return nil
  }
  
  /**
  - returns: nil if result is an empty string, block allows text munging of result if there is one
  */
  class func extract_data(subject: XMLElement, query: String) -> String? {
    let result = subject.xpath(query).first?.stringValue
    if let result = result where result != "" {
      return result
    }
    return nil
  }
  
}
