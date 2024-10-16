//
//  Vehicle.swift
//  Safe_Driver_Sim
//
//  Created by Alex Nunez on 10/15/24.
//

import Foundation
import Observation

@Observable
final class Vehicle {
    // Variables
    var vehicle_id: String
    var isRetrieving = false
    private let synchronized = DispatchQueue(label: "synchronized", qos: .background)
    private let serverUrl = "http:/127.0.0.1:5000/"
    
    // Functions
    init(_ vid: String) {
        vehicle_id = vid
    }
    
    func postLocation() {
        synchronized.sync {
            guard !self.isRetrieving else {
                return
            }
            self.isRetrieving = true
        }
        
        guard let apiurl = URL(string: "\(serverUrl)api/v1/vehicles/location/\(vehicle_id)/") else {
            print("postLocation: Bad URL")
            return
        }
        
        let jsonObj = ["vehicle_id": vehicle_id,
                       "latitude": LocManager.shared.location.coordinate.latitude,
                       "longitude": LocManager.shared.location.coordinate.longitude,
        ] as [String : Any]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postLocation: jsonData serialization error")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            var request = URLRequest(url: apiurl)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil else {
                    print("postLocation: NETWORKING ERROR")
                    return
                }

                if let httpStatus = response as? HTTPURLResponse {
                    if httpStatus.statusCode != 200 {
                        print("postLocation: HTTP STATUS: \(httpStatus.statusCode)")
                        return
                    }
                }

            }.resume()
        }
        
    }
    
    func loginVehicle() {
        guard let apiurl = URL(string: "\(serverUrl)api/v1/vehicles/login/\(vehicle_id)/") else {
            print("loginVehicle: Bad URL")
            return
        }
        DispatchQueue.global(qos: .background).async {
            var request = URLRequest(url: apiurl)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil else {
                    print("loginVehicle: NETWORKING ERROR")
                    return
                }

                if let httpStatus = response as? HTTPURLResponse {
                    if httpStatus.statusCode != 200 {
                        print("loginVehicle: HTTP STATUS: \(httpStatus.statusCode)")
                        return
                    }
                }

            }.resume()
        }
    }
    
    func logoutVehicle() {
        
    }
}
