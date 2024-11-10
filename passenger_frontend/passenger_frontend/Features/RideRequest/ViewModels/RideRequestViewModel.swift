import Foundation
import CoreLocation
import Combine

enum RideRequestState: Equatable {
    case idle
    case loading
    case success
    case error(String)
    
    // Implement Equatable manually because of associated value
    static func == (lhs: RideRequestState, rhs: RideRequestState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

class RideRequestViewModel: ObservableObject {
    @Published var state: RideRequestState = .idle
    @Published var authViewModel: AuthViewModel?
    
    // Response model for the ride request
    struct RideRequestResponse: Codable {
        let requestId: String
        let estimatedTime: Int
        let estimatedPrice: Double
        // Add other response fields as needed
    }
        
    // valid pickup locations
    var validPickupLocations: [String] = ["Bob and Betty Biester", "LSA", "Duderstadt Center"]
    
    // Request model for the ride request
    struct RideRequestBody: Codable {
        let uuid: String
        let serviceName: String
        let pickupLocation: String
        let dropoffLocation: String
        let dropoffLat: Double
        let dropoffLong: Double
        let rideOrigin: String
        let numPassengers: Int
    }
    
    func requestRide(
        service: Service,
        pickupLocation: String,
        dropoffLocationName: String,
        dropoffLocation: CLLocationCoordinate2D
    ) {
        state = .loading
        
        guard let userId = authViewModel?.user?.id else {
            state = .error("User not authenticated")
            return
        }
        
        let requestBody = RideRequestBody(
            uuid: userId,
            serviceName: service.serviceName,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocationName,
            dropoffLat: dropoffLocation.latitude,
            dropoffLong: dropoffLocation.longitude,
            rideOrigin: "passenger",
            numPassengers: 1
        )
        
        guard let url = URL(string: "http://35.2.2.224:5000/api/v1/rides/") else {
            state = .error("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            print("📤 Sending request with body:", requestBody)
        } catch {
            state = .error("Failed to encode request body")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error:", error.localizedDescription)
                    self?.state = .error(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from server")
                    self?.state = .error("No data received")
                    return
                }
                
                // Print raw response data for debugging
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("📥 Raw server response:", rawResponse)
                }
                
                do {
                    let response = try JSONDecoder().decode(RideRequestResponse.self, from: data)
                    print("✅ Request successful! Response:", response)
                    self?.state = .success
                } catch {
                    print("❌ Decoding error:", error.localizedDescription)
                    self?.state = .error("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
