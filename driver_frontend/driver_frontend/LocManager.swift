//
//  LocManager.swift
//  driver_frontend
//
//  Created by James Nesbitt on 11/9/24.
//
import MapKit
import Observation


@Observable
final class LocManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocManager()
    private let locManager = CLLocationManager()
    
    override private init() {
        super.init()

        // configure the location manager
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.delegate = self
    }
    private(set) var location = CLLocation()

        func startUpdates() {
            if locManager.authorizationStatus == .notDetermined {
                // ask for user permission if undetermined
                // Be sure to add 'Privacy - Location When In Use Usage Description' to
                // Info.plist, otherwise location read will fail silently,
                // with (lat/lon = 0)
                locManager.requestWhenInUseAuthorization()
            }
        
            Task {
                do {
                    for try await update in CLLocationUpdate.liveUpdates() {
                        location = update.location ?? location
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        } 
}
