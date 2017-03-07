//
//  ccda_medication_importer.swift
//  CDAKit
//
//  Created by Eric Whitley on 1/25/16.
//  Copyright © 2016 Eric Whitley. All rights reserved.
//

import Foundation

class CDAKImport_CCDA_MedicationImporter: CDAKImport_CDA_MedicationImporter {
  
  override init(entry_finder: CDAKImport_CDA_EntryFinder = CDAKImport_CDA_EntryFinder(entry_xpath: "//cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.22.2.1' or cda:templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/cda:entry/cda:substanceAdministration")) {
    super.init(entry_finder: entry_finder)

    indication_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.19']"
    vehicle_xpath = "./cda:participant/cda:participantRole[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.24']/cda:playingEntity/cda:code"
    fill_number_xpath = "./cda:repeatNumber"
    
    precondition_xpath = "./cda:precondition[@typeCode='PRCN' and cda:templateId/@root='2.16.840.1.113883.10.20.22.4.25']/cda:criterion"

    reaction_xpath = "./cda:entryRelationship[@typeCode='MFST']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.9']"
    severity_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.8']"

    
  }
  
}
