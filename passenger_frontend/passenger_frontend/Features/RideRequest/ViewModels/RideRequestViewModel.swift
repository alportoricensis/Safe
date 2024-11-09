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
    
    // Request model for the ride request
    struct RideRequestBody: Codable {
        let serviceId: String
        let pickupLatitude: Double
        let pickupLongitude: Double
        let destinationLatitude: Double
        let destinationLongitude: Double
        let pickupAddress: String
        let destinationAddress: String
    }
    
    func requestRide(
        service: Service,
        pickupLocation: CLLocationCoordinate2D,
        destinationLocation: CLLocationCoordinate2D,
        pickupAddress: String,
        destinationAddress: String
    ) {
        state = .loading
        
        let requestBody = RideRequestBody(
            serviceId: service.id.uuidString,
            pickupLatitude: pickupLocation.latitude,
            pickupLongitude: pickupLocation.longitude,
            destinationLatitude: destinationLocation.latitude,
            destinationLongitude: destinationLocation.longitude,
            pickupAddress: pickupAddress,
            destinationAddress: destinationAddress
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
