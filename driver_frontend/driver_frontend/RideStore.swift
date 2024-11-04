//
//  RideStore.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 11/1/24.
//

import Foundation
import Observation

@Observable
final class RideStore {
    static let shared = RideStore() 
    private init() {}
                                     

    private var isRetrieving = false
    private let synchronized = DispatchQueue(label: "synchronized", qos: .background)

    private(set) var rides = [Ride]()
    private let nFields = Mirror(reflecting: Ride()).children.count-1

    private let serverUrl = "https://mada.eecs.umich.edu/"
    
    
    func getRides(){
        self.rides = [
            Ride(pickcupLoc: "Location A", dropLoc: "Location B", passenger: "Pass A", id: UUID()),
            Ride(pickcupLoc: "Location C", dropLoc: "Location D", passenger: "Pass B", id: UUID())
                ]
        
    }
}
