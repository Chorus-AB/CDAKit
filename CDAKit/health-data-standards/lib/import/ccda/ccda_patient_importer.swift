//
//  ccda_patient_importer.swift
//  CDAKit
//
//  Created by Eric Whitley on 1/25/16.
//  Copyright © 2016 Eric Whitley. All rights reserved.
//

import Foundation
import Fuzi

class CDAKImport_CCDA_PatientImporter: CDAKImport_C32_PatientImporter {

  override init(check_usable: Bool = true) {

    super.init(check_usable: check_usable) //NOTE: original Ruby does NOT call super
    
    section_importers["encounters"] = CDAKImport_CCDA_EncounterImporter()
    section_importers["procedures"] = CDAKImport_CCDA_ProcedureImporter()
    section_importers["results"] = CDAKImport_CCDA_ResultImporter()
    section_importers["vital_signs"] = CDAKImport_CCDA_VitalSignImporter()
    section_importers["medications"] = CDAKImport_CCDA_MedicationImporter()
    section_importers["conditions"] = CDAKImport_CCDA_ConditionImporter()
    section_importers["social_history"] = CDAKImport_CCDA_SocialHistoryImporter()

    section_importers["care_goals"] = CDAKImport_CCDA_CareGoalImporter()
    section_importers["medical_equipment"] = CDAKImport_CCDA_MedicalEquipmentImporter()
    section_importers["allergies"] = CDAKImport_CCDA_AllergyImporter()
    section_importers["immunizations"] = CDAKImport_CCDA_ImmunizationImporter()
    section_importers["insurance_providers"] = CDAKImport_CCDA_InsuranceProviderImporter()
  }
  
  
  func parse_ccda(_ doc: XMLDocument) -> CDAKRecord {
    return parse_c32(doc)
  }

}
