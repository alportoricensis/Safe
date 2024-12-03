
import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    private var cancellables = Set<AnyCancellable>()
    private var vehicleId: String?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        print("LocationManager initialized and authorization requested.")
    }
    
    func setVehicleId(_ id: String) {
        self.vehicleId = id
        print("Vehicle ID set to: \(id)")
        // Start location updates and timer once the vehicle ID is set
        startLocationUpdates()
    }
    
    // CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("No locations received.")
            return
        }
        DispatchQueue.main.async {
            self.location = location
            self.authorizationStatus = manager.authorizationStatus
            //print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            print("Authorization status changed to: \(status.rawValue)")
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
                print("Started updating location.")
            } else {
                self.locationManager.stopUpdatingLocation()
                print("Stopped updating location due to authorization status.")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
    
    private func startLocationUpdates() {
        // Cancel any existing timer if it exists
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.sendLocationToServer()
        }
        print("Timer scheduled to send location every 10 seconds.")
    }
    
    private func sendLocationToServer() {
        guard let vehicleId = vehicleId, let location = location else {
            print("Vehicle ID or location data is missing.")
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // API URL
        guard let url = URL(string: "http://18.191.14.26/api/v1/vehicles/location/") else { 
            print("Invalid URL")
            return
        }
        
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let locationData: [String: Any] = [
            "vehicle_id": vehicleId,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: locationData, options: [])
            
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending location: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Server error: \(httpResponse.statusCode)")
                    return
                }
                if let data = data, let responseJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Location update response: \(responseJson["msg"] as? String ?? "Unknown response")")
                } else {
                    print("Unable to parse response.")
                }
            }.resume()
        } catch {
            print("Error encoding location data: \(error.localizedDescription)")
        }
    }
}
