import Foundation

struct Booking: Identifiable, Codable {
    let id: Int
    let pickupLat: Double
    let pickupLong: Double
    let dropoffLat: Double
    let dropoffLong: Double
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
        case status
    }
}

struct BookingsResponse: Codable {
    let requests: [Booking]
}
