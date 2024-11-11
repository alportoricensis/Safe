import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    private var timer: Timer?
    private var vehicleId: String?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func setVehicleId(_ id: String) {
        self.vehicleId = id
        // Start location updates only once the vehicle ID is set
        startLocationUpdates()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }

    private func startLocationUpdates() {
        // Cancel any existing timer if it exists
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.sendLocationToServer()
        }
    }

    private func sendLocationToServer() {
        guard let vehicleId = vehicleId, let location = location else {
            print("Vehicle ID or location data is missing.")
            return
        }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        // API URL
        guard let url = URL(string: "http://35.2.2.224:5000/api/v1/vehicles/location/") else {
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
                if let data = data, let responseJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Location update response: \(responseJson["msg"] as? String ?? "Unknown response")")
                }
            }.resume()
        } catch {
            print("Error encoding location data: \(error.localizedDescription)")
        }
    }
}
