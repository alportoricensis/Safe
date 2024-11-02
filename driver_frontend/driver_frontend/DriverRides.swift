//
//  DriverRides.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 11/1/24.
//

import Foundation

struct Ride: Identifiable {
    var pickcupLoc: String?
    var dropLoc: String?
    var id: UUID?
    
    static func ==(lhs: Ride, rhs: Ride) -> Bool {
        lhs.id == rhs.id
    }
}
