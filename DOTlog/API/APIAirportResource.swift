//
//  SyncAirports.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/08.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class APIAirportResource : APIResource {

	// *******  DOT MAY HAVE TO UPDATE BASED ON DOTLOG INSTALLATION DIRECTORY STRUCTURE  ******* //
	private let airportURI = "/dotlog/api/index.cfm/api/airports"
	// *******  DOT MAY HAVE TO UPDATE BASED ON DOTLOG INSTALLATION DIRECTORY STRUCTURE  ******* //


	private let httpMethod = "GET"
	private var APIAddressString : String
	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	init (baseURLString base: String){
		APIAddressString = base + airportURI
	}

	func accept(visitor : NetworkVisitor){
		visitor.visit(self)
	}

	func getMethod() -> String{
		return httpMethod
	}

	func getAPIAddressString() -> String {
		return APIAddressString
	}

	func getBody() -> NSData? {
		return nil
	}

	func getResourceIdentifier () -> String {
		return airportURI
	}

	func refreshLocalResource(webData: NSMutableData) -> NSError? {
		var error: NSError?
		let errorinfo = ["NSLocalizedDescriptionKey":"Bad data received for from airport resource \(getAPIAddressString())"]

		let regionData = JSON(data: webData, error: &error)
		//		let data = JSON(data: webData, error: &error)["AIRPORTS"]
		let regionDescription = NSEntityDescription.entityForName("RegionEntry", inManagedObjectContext: managedObjectContext!)
		let districtDescription = NSEntityDescription.entityForName("DistrictEntry", inManagedObjectContext: managedObjectContext!)
		let hubDescription = NSEntityDescription.entityForName("HubEntry", inManagedObjectContext: managedObjectContext!)
		let airportDescription = NSEntityDescription.entityForName("AirportEntry", inManagedObjectContext: managedObjectContext!)

		if regionData.error == nil {
			// Do more error checking first
			// Potentially add API validation functions. This deletes all airports and does inline error checking while inserting them afterward.
			deleteOld()

			var newRegions : [RegionEntry] = []
			var newDistricts : [DistrictEntry] = []
			var newHubs : [HubEntry] = []
			var newAirports : [AirportEntry] = []

			for (index,region) in regionData {
				if let regionName = region["REGION_NAME"].string {
					// New Region Object
					let districtData = region["DISTRICTS"]
					let regionObj = RegionEntry(entity: regionDescription!, insertIntoManagedObjectContext: managedObjectContext)
					regionObj.region_name = regionName

					if districtData.type == .Array {
						for (index, district) in districtData {
							if let districtName = district["DISTRICT_NAME"].string {
								// New District Object
								let hubData = district["HUBS"]
								let districtObj = DistrictEntry(entity: districtDescription!, insertIntoManagedObjectContext: managedObjectContext)
								districtObj.district_name = districtName
								districtObj.region = regionObj

								var mutableDistricts = regionObj.district.mutableCopy() as! NSMutableOrderedSet
								mutableDistricts.addObject(districtObj)
								regionObj.district = mutableDistricts.copy() as! NSOrderedSet

								if hubData.type == .Array {
									for (index, hub) in hubData {
										if let hubName = hub["HUB_NAME"].string {
											// New Hub Object
											let airportData = hub["AIRPORTS"]
											let hubObj = HubEntry(entity: hubDescription!, insertIntoManagedObjectContext: managedObjectContext)
											hubObj.hub_name = hubName
											hubObj.district = districtObj

											var mutableHubs = districtObj.hub.mutableCopy() as! NSMutableOrderedSet
											mutableHubs.addObject(hubObj)
											districtObj.hub = mutableHubs.copy() as! NSOrderedSet

											if airportData.type == .Array {
												for (index, airport) in airportData {
													if let airportName = airport["FAA_CODE"].string {
														// New Airport Object
														let airportObj = AirportEntry(entity: airportDescription!, insertIntoManagedObjectContext: managedObjectContext)
														airportObj.faa_code = airportName
														airportObj.hub = hubObj

														var mutableAirports = hubObj.airport.mutableCopy() as! NSMutableOrderedSet
														mutableAirports.addObject(airportObj)
														hubObj.airport = mutableAirports.copy() as! NSOrderedSet

														managedObjectContext?.save(&error)
													}
												}
											}
											else {
												// error no airports in hub
												error = NSError (domain: "API Airport", code: 10, userInfo: errorinfo)
												return error
											}
										}
									}
								}
								else {
									// error no hubs in district
									error = NSError (domain: "API Airport", code: 11, userInfo: errorinfo)
									return error
								}
							}
						}
					}
					else {
						// error no districts in region
						error = NSError (domain: "API Airport", code: 12, userInfo: errorinfo)
						return error
					}
				}
			}
		}

		else {
			error = NSError (domain: "API Airport", code: 13, userInfo: errorinfo)
		}

		return error
	}

	private func deleteOld() {
		// Core data delete rules are cascade -- deleting region deletes all children
		let fetch = NSFetchRequest (entityName: "RegionEntry")
		let airports = managedObjectContext!.executeFetchRequest(fetch, error: nil) as! [RegionEntry]
		
		for airport in airports {
			managedObjectContext?.deleteObject(airport)
		}
		managedObjectContext?.save(nil)

	}
}