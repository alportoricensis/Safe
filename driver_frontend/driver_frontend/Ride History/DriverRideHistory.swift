//
//  DriverRideHistory.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 12/3/24.
//

import Foundation
import Foundation
struct DriverRideHistory: Identifiable {
    var rideDate: String?
    var passCount: String?
    var miles: String?
    var id: String?
    
    static func ==(lhs: DriverRideHistory, rhs: DriverRideHistory) -> Bool {
        lhs.id == rhs.id
    }
}
