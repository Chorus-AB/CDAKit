//
//  allergy_importer.swift
//  CDAKit
//
//  Created by Eric Whitley on 1/13/16.
//  Copyright © 2016 Eric Whitley. All rights reserved.
//

import Foundation
import Fuzi


//TODO: Coded Product Name, Free Text Product Name, Coded Brand Name and Free Text Brand name need to be pulled out separatelty This would mean overriding extract_codes
//TODO: Patient Instructions needs to be implemented. Will likely be a reference to the narrative section
//TODO: Couldn't find an example medication reaction. Isn't clear to me how it should be implemented from the specs, so reaction is not implemented.
//TODO: Couldn't find an example dose indicator. Isn't clear to me how it should be implemented from the specs, so dose indicator is not implemented.
//TODO: Fill Status is not implemented. Couldn't figure out which entryRelationship it should be nested in
class CDAKImport_CDA_MedicationImporter: CDAKImport_CDA_SectionImporter {

  var type_of_med_xpath: String? = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.8.1']/cda:code"
//  var indication_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.28']/cda:code"

  var indication_xpath = "./cda:entryRelationship[@typeCode='RSON']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.28']"

  var vehicle_xpath = "cda:participant/cda:participantRole[cda:code/@code='412307009' and cda:code/@codeSystem='2.16.840.1.113883.6.96']/cda:playingEntity/cda:code"
  var fill_number_xpath = "./cda:entryRelationship[@typeCode='COMP']/cda:sequenceNumber/@value"
  
  var precondition_xpath = "./cda:precondition[@typeCode='PRCN' and cda:templateId/@root='2.16.840.1.113883.10.20.22.4.25']/cda:criterion"

  var reaction_xpath = "./cda:entryRelationship[@typeCode='MFST']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.54']"
  var severity_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.55']"


  // TODO: Maybe I could simplify this according to code_xpath and description_xpath?
  var manufactured_product_xpath = "./cda:consumable/cda:manufacturedProduct[@classCode='MANU' and cda:templateId/@root='2.16.840.1.113883.10.20.22.4.54']"

  
  override init(entry_finder: CDAKImport_CDA_EntryFinder = CDAKImport_CDA_EntryFinder(entry_xpath: "//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.112']/cda:entry/cda:substanceAdministration")) {
    super.init(entry_finder: entry_finder)
    
    code_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code"
    description_xpath = "./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code/cda:originalText/cda:reference[@value]"
    
    entry_class = CDAKMedication.self
  }
  
  override func create_entry(_ entry_element: XMLElement, nrh: CDAKImport_CDA_NarrativeReferenceHandler = CDAKImport_CDA_NarrativeReferenceHandler()) -> CDAKMedication? {
    
    if let medication = super.create_entry(entry_element, nrh: nrh) as? CDAKMedication {

      extract_administration_timing(entry_element, medication: medication)
      
      medication.route.addCodes(CDAKImport_CDA_SectionImporter.extract_code(entry_element, code_xpath: "./cda:routeCode"))
      if let a_dose = extract_scalar(entry_element, scalar_xpath: "./cda:doseQuantity") {
        medication.dose = a_dose
      }
      if let a_rate = extract_scalar(entry_element, scalar_xpath: "./cda:rateQuantity") {
        medication.rate = a_rate
      }
      
      medication.anatomical_approach.addCodes(CDAKImport_CDA_SectionImporter.extract_code(entry_element, code_xpath: "./cda:approachSiteCode", code_system: "SNOMED-CT", force_code_system: false))
      
      extract_dose_restriction(entry_element, medication: medication)
      
      medication.product_form.addCodes(CDAKImport_CDA_SectionImporter.extract_code(entry_element, code_xpath: "./cda:administrationUnitCode", code_system: "NCI Thesaurus", force_code_system: false))
      medication.delivery_method.addCodes(CDAKImport_CDA_SectionImporter.extract_code(entry_element, code_xpath: "./cda:code", code_system: "SNOMED-CT", force_code_system: false))
      if let type_of_med_xpath = type_of_med_xpath {
        medication.type_of_medication.addCodes(CDAKImport_CDA_SectionImporter.extract_code(entry_element, code_xpath: type_of_med_xpath, code_system: "SNOMED-CT", force_code_system: false))
      }

      medication.indication = extract_entry_detail(entry_element, xpath: indication_xpath)
      medication.indication?.codes.preferred_code_sets = ["SNOMED-CT"]

      
      if let precondition_entry = entry_element.xpath(precondition_xpath).first {
        if let codes = CDAKImport_CDA_SectionImporter.extract_codes(precondition_entry, code_xpath: "cda:value") {
          medication.precondition = codes
          medication.precondition.preferred_code_sets = ["SNOMED-CT"]
        }
      }
      
      medication.reaction = extract_entry_detail(entry_element, xpath: reaction_xpath)
      medication.reaction?.codes.preferred_code_sets = ["SNOMED-CT"]
      medication.severity = extract_entry_detail(entry_element, xpath: severity_xpath)
      medication.severity?.codes.preferred_code_sets = ["SNOMED-CT"]

      medication.material_name = extract_material_name(entry_element)
      medication.manufacturer_organization = extract_manufacturer_organization(entry_element)

      medication.vehicle.addCodes(CDAKImport_CDA_SectionImporter.extract_code(entry_element, code_xpath: vehicle_xpath, code_system: "SNOMED-CT", force_code_system: false))
      
      extract_order_information(entry_element, medication: medication)
      
      extract_fulfillment_history(entry_element, medication: medication)
      extract_negation(entry_element, entry: medication)
      
      return medication
    }
    
    return nil

  }

  fileprivate func extract_fulfillment_history(_ parent_element: XMLElement, medication: CDAKMedication) {
    let fhs = parent_element.xpath("./cda:entryRelationship/cda:supply[@moodCode='EVN']")
    for fh_element in fhs {
      let fulfillment_history = CDAKFulfillmentHistory()
      fulfillment_history.prescription_number = fh_element.xpath("./cda:id").first?["root"]
      if let actor_element = fh_element.xpath("./cda:performer").first {
        fulfillment_history.provider = import_actor(actor_element)
      }
      if let hl7_timestamp = fh_element.xpath("./cda:effectiveTime").first?["value"] {
        fulfillment_history.dispense_date = CDAKHL7Helper.timestamp_to_integer(hl7_timestamp)
      }
      if let quantity_dispensed = extract_scalar(fh_element, scalar_xpath: "./cda:quantity") {
        fulfillment_history.quantity_dispensed = quantity_dispensed
      }
      if let fill_number = fh_element.xpath(fill_number_xpath).first?.stringValue, let fill_number_int = Int(fill_number) {
        fulfillment_history.fill_number = fill_number_int
      }
      medication.fulfillment_history.append(fulfillment_history)
    }
  }

  
  fileprivate func extract_order_information(_ parent_element: XMLElement, medication: CDAKMedication) {
    let order_elements = parent_element.xpath("./cda:entryRelationship[@typeCode='REFR']/cda:supply[@moodCode='INT']")
    for order_element in order_elements {
      let order_information = CDAKOrderInformation()
      if let actor_element = order_element.xpath("./cda:author").first {
        //this looks like it might explode
        order_information.provider = CDAKImport_ProviderImportUtils.extract_provider(actor_element, element_name: "assignedAuthor")
      }
      
      order_information.order_number = order_element.xpath("./cda:id").first?["root"]
      if let fills = order_element.xpath("./cda:repeatNumber").first?["value"], let fills_int = Int(fills) {
        order_information.fills = fills_int
      }
      if let quantity_ordered = extract_scalar(order_element, scalar_xpath: "./cda:quantity") {
        order_information.quantity_ordered = quantity_ordered
      }
      medication.order_information.append(order_information)
    }
  }

  fileprivate func extract_administration_timing(_ parent_element: XMLElement, medication: CDAKMedication) {
    if let administration_timing_element = parent_element.xpath("./cda:effectiveTime[2]").first {
      if let institutionSpecified = administration_timing_element["institutionSpecified"] {
        let inst = institutionSpecified.lowercased().trimmingCharacters(in: .whitespaces)
        switch inst {
        case "true": medication.administration_timing.institution_specified = true
        case "false": medication.administration_timing.institution_specified = false
        default: print("CDA importer - extract_administration_timing() - institutionSpecified - found unknown value \(inst)")
        }
      }
      if let period = extract_scalar(administration_timing_element, scalar_xpath: "./cda:period") {
        medication.administration_timing.period = period
      }
    }
  }

  fileprivate func extract_manufacturer_organization(_ parent_element: XMLElement) -> String? {
    if let manufactured_product_element = parent_element.xpath(manufactured_product_xpath).first {
      return manufactured_product_element.xpath("./cda:manufacturerOrganization/cda:name").first?.stringValue;
    }
    return nil;
  }

  fileprivate func extract_material_name(_ parent_element: XMLElement) -> String? {
    if let manufactured_product_element = parent_element.xpath(manufactured_product_xpath).first {
      if let name = manufactured_product_element.xpath("./cda:manufacturedMaterial/cda:name").first {

        var result:String?;

        let delimiter:String = name.firstChild(tag: "delimiter")?.stringValue ?? " ";

        if let prefix:XMLElement = name.firstChild(tag: "prefix"), !prefix.isBlank {
          result = result ?? "" + prefix.stringValue + delimiter;
        }

        if let given:XMLElement = name.firstChild(tag: "given"), !given.isBlank {
          result = result ?? "" + given.stringValue + delimiter;
        }

        if let family:XMLElement = name.firstChild(tag: "family"), !family.isBlank {
          result = result ?? "" + family.stringValue + delimiter;
        }

        if let suffix:XMLElement = name.firstChild(tag: "suffix"), !suffix.isBlank {
          result = result ?? "" + suffix.stringValue + delimiter;
        }

        if let result = result {
          return result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
        }

      }
    }
    return nil;
  }

  fileprivate func extract_dose_restriction(_ parent_element: XMLElement, medication: CDAKMedication) {
    if let dre = parent_element.xpath("./cda:maxDoseQuantity").first {
      if let numerator = extract_scalar(dre, scalar_xpath: "./cda:numerator") {
        medication.dose_restriction.numerator = numerator
      }
      if let denominator = extract_scalar(dre, scalar_xpath: "./cda:denominator") {
        medication.dose_restriction.denominator = denominator
      }
    }
  }

  
}
