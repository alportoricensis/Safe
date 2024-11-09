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
    
    // Response model for the ride request
    struct RideRequestResponse: Codable {
        let requestId: String
        let estimatedTime: Int
        let estimatedPrice: Double
        // Add other response fields as needed
    }
        
    // valid pickup locations
    var validPickupLocations: [String] = ["Bob and Betty Biester", "LSA", "Duderstadt"]
    
    // Request model for the ride request
    struct RideRequestBody: Codable {
        let uuid: String
        let service: String
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
        
        let requestBody = RideRequestBody(
            uuid: UUID().uuidString,
            service: service.serviceName,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocationName,
            dropoffLat: dropoffLocation.latitude,
            dropoffLong: dropoffLocation.longitude,
            rideOrigin: "passenger",
            numPassengers: 1
        )
        
        // TODO: Make actual API request here
        // Example structure:
        /*
        apiClient.post(
            endpoint: "ride-requests",
            body: requestBody
        ) { [weak self] (result: Result<RideRequestResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.state = .success
                    // Handle successful response
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
        */
    }
}
