//
//  DriverRides.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 11/1/24.
//


import Foundation
import CoreLocation

struct Ride: Identifiable {
    var pickupLoc: String
    var dropLoc: String
    var passenger: String
    var status: String
    var id: String // Non-optional
    
    var pickupLatitude: Double
    var pickupLongitude: Double
    var dropOffLatitude: Double
    var dropOffLongitude: Double




    static func ==(lhs: Ride, rhs: Ride) -> Bool {
        lhs.id == rhs.id
    }
}

extension Ride {
    var pickupCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: pickupLatitude, longitude: pickupLongitude)
    }

    var dropOffCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: dropOffLatitude, longitude: dropOffLongitude)
    }
}
