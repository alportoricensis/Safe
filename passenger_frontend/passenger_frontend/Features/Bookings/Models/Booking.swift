import Foundation

struct Booking: Identifiable, Codable {
    let id: Int
    let pickupLat: Double
    let pickupLong: Double
    let dropoffLat: Double
    let dropoffLong: Double
    let requestTime: String
    let pickupTime: String?
    let dropoffTime: String?
    let serviceName: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ride_id"
        case pickupLat = "pickup_lat"
        case pickupLong = "pickup_long"
        case dropoffLat = "dropoff_lat"
        case dropoffLong = "dropoff_long"
        case pickupTime = "pickup_time"
        case dropoffTime = "dropoff_time"
        case serviceName = "service_name"
        case requestTime = "request_time"
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        pickupLat = try container.decode(Double.self, forKey: .pickupLat)
        pickupLong = try container.decode(Double.self, forKey: .pickupLong)
        dropoffLat = try container.decode(Double.self, forKey: .dropoffLat)
        dropoffLong = try container.decode(Double.self, forKey: .dropoffLong)
        requestTime = try container.decode(String.self, forKey: .requestTime)
        serviceName = try container.decode(String.self, forKey: .serviceName)
        status = try container.decode(String.self, forKey: .status)
        
        let pickupTimeString = try container.decode(String.self, forKey: .pickupTime)
        pickupTime = pickupTimeString == "None" ? nil : pickupTimeString
        
        let dropoffTimeString = try container.decode(String.self, forKey: .dropoffTime)
        dropoffTime = dropoffTimeString == "None" ? nil : dropoffTimeString
    }
}

struct BookingsResponse: Codable {
    let requests: [Booking]
}
