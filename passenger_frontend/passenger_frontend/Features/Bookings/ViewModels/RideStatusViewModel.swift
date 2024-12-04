import Foundation
import Combine
import CoreLocation

class RideStatusViewModel: ObservableObject {
    @Published var rideStatus: RideStatus?
    @Published var error: Error?
    @Published var driverItinerary: [ItineraryStop] = []
    
    private var timer: Timer?
    private let rideId: Int
    
    private let geocoder = CLGeocoder()
    
    init(rideId: Int) {
        self.rideId = rideId
        startPolling()
    }
    
    deinit {
        stopPolling()
    }
    
    private func startPolling() {
        // Initial fetch
        fetchRideStatus()
        
        // Set up timer for polling every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.fetchRideStatus()
        }
    }
    
    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchRideStatus() {
        guard let url = URL(string: "http://18.191.14.26/api/v1/rides/passengers/\(rideId)/") else {
            print("⚠️ Invalid URL constructed for rideId: \(rideId)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            print("🔄 Fetching ride status for ride #\(self?.rideId ?? 0)")
            
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from API")
                    return
                }
                
                print("📦 Received data: \(String(data: data, encoding: .utf8) ?? "Unable to stringify data")")
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                    let response = try decoder.decode([String: RideStatus].self, from: data)
                    print("🎯 Decoded response: \(response)")
                    
                    // Convert the rideId to String since that's how it's keyed in the response
                    if var status = response[String(self?.rideId ?? 0)] {
                        self?.rideStatus = status
                        print("✅ Updated ride status")
                        
                        // Fetch driver itinerary after getting ride status
                        self?.fetchDriverItinerary(status: status)
                    } else {
                        print("⚠️ No ride status found for ride #\(self?.rideId ?? 0)")
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    print("Decoding error details:", error.localizedDescription)
                    self?.error = error
                }
            }
        }.resume()
    }
    
    private func reverseGeocode(coordinates: [Double], completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    completion("Address unavailable")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let address = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea
                    ]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    completion(address)
                } else {
                    completion("Address unavailable")
                }
            }
        }
    }
    private func fetchDriverItinerary(status: RideStatus) {
        let vehicleId = status.driver
        
        guard let url = URL(string: "http://18.191.14.26/api/v1/rides/drivers/\(vehicleId)/") else {
            print("⚠️ Invalid URL for driver itinerary")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let data = data else { return }
                
                do {
                    let response = try JSONDecoder().decode(DriverItineraryResponse.self, from: data)
                    
                    var stops: [ItineraryStop] = []
                    var rideOccurrenceCount: [String: Int] = [:]
                    
                    // Iterate through the rideOrder
                    for rideId in response.rideOrder {
                        guard let rideInfo = response.additionalInfo[rideId] else { continue }
                        
                        // Increment occurrence count
                        rideOccurrenceCount[rideId, default: 0] += 1
                        let occurrence = rideOccurrenceCount[rideId]!
                        
                        // Determine action based on occurrence
                        let action = occurrence == 1 ? "pickup" : "dropoff"
                        
                        // Create ItineraryStop
                        let stop = ItineraryStop(
                            id: rideId,
                            location: action == "pickup" ? rideInfo.pickup : rideInfo.dropoff,
                            action: action,
                            currentRideId: status.reqid
                        )
                        
                        stops.append(stop)
                    }
                    
                    // Simplify consecutive duplicate pickups
                    var simplifiedStops: [ItineraryStop] = []
                    var previousStop: ItineraryStop?
                    
                    for stop in stops {
                        if let prev = previousStop,
                           prev.action == stop.action,
                           prev.location == stop.location {
                            // Skip duplicate
                            continue
                        } else {
                            simplifiedStops.append(stop)
                            previousStop = stop
                        }
                    }
                    
                    self?.driverItinerary = simplifiedStops
                    
                    // Print detailed itinerary information
                    print("🚗 Driver Itinerary:")
                    print("Driver ID: \(vehicleId)")
                    print("Number of stops: \(simplifiedStops.count)")
                    for (index, stop) in simplifiedStops.enumerated() {
                        print("\nStop #\(index + 1):")
                        print("Ride ID: \(stop.id)")
                        print("Action: \(stop.action.capitalized)")
                        print("Location: \(stop.location)")
                        print("Is Current Ride: \(stop.isCurrentRide)")
                        print("---")
                    }
                    
                } catch {
                    print("❌ Failed to decode driver itinerary: \(error)")
                    print("Error details: \(error.localizedDescription)")
                    self?.error = error
                }
            }
        }.resume()
    }
}

// Model to match the API response
struct RideStatus: Codable, Identifiable {
    let ETA: Date
    let ETP: Date
    let driver: String
    let driverLat: Double
    let driverLong: Double
    let dropoff: String
    let passenger: String
    let pickup: String
    let reqid: String
    
    var id: String { reqid }
    
    var dropoffFormatted: String { dropoff }
}

// Add new model for itinerary stops
struct ItineraryStop: Identifiable {
    let id: String
    let location: String
    let action: String  // "pickup" or "dropoff"
    let isCurrentRide: Bool
    
    var identifier: String { "\(id)-\(action)" }
    var displayText: String { "\(action.capitalized) at \(location)" }
    
    init(id: String, location: String, action: String, currentRideId: String) {
        self.id = id
        self.location = location
        self.action = action
        self.isCurrentRide = (id == currentRideId)
    }
}

// Date formatter extension
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// Add these structs for decoding the driver itinerary response
struct DriverItineraryResponse: Codable {
    let rideOrder: [String]
    let additionalInfo: [String: RideInfo]
    
    // Custom coding keys to handle dynamic ride IDs
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
        
        static let rideOrder = CodingKeys(stringValue: "rideOrder")!
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rideOrder = try container.decode([String].self, forKey: .rideOrder)
        
        // Decode all other keys as RideInfo
        var tempAdditionalInfo: [String: RideInfo] = [:]
        for key in container.allKeys where key.stringValue != "rideOrder" {
            tempAdditionalInfo[key.stringValue] = try container.decode(RideInfo.self, forKey: key)
        }
        additionalInfo = tempAdditionalInfo
    }
    
    // Add encode method to conform to Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rideOrder, forKey: .rideOrder)
        
        // Encode each ride info with its ID as the key
        for (key, value) in additionalInfo {
            let dynamicKey = CodingKeys(stringValue: key)!
            try container.encode(value, forKey: dynamicKey)
        }
    }
    
    // Helper method to get ride info
    func getRideInfo(for rideId: String) -> RideInfo? {
        return additionalInfo[rideId]
    }
}

struct RideInfo: Codable {
    let pickup: String
    let dropoff: String
    let ETP: String
    // Add other fields if needed
}
