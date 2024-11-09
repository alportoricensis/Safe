import Foundation
import Observation

@Observable
final class RideStore {
    static let shared = RideStore()
    private init() {}

    private var isRetrieving = false
    private let synchronized = DispatchQueue(label: "synchronized", qos: .background)

    private(set) var rides = [Ride]()
    private let nFields = Mirror(reflecting: Ride()).children.count - 1

    private let serverUrl = "https://35.3.200.144:5000/api/v1/rides/"
    var username = ""
    var password = ""

    func getRides() async {
        synchronized.sync {
            guard !self.isRetrieving else { return }
            self.isRetrieving = true
        }
        

        guard let apiUrl = URL(string: serverUrl) else {
            print("getRides: Bad URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getRides: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("getRides: JSON deserialization failed")
                return
            }
            
            var fetchedRides = [Ride]()
            for (rideID, rideData) in jsonObj {
                if let rideInfo = rideData as? [String: Any] {
                    let pickup = rideInfo["pickup"] as? String ?? "Unknown"
                    let dropoff = rideInfo["dropoff"] as? String ?? "Unknown"
                    let rideId = UUID(uuidString: rideID) ?? UUID()
                    
                    fetchedRides.append(Ride(
                        pickupLoc: pickup,
                        dropLoc: dropoff,
                        id: rideId
                    ))
                }
            }

            synchronized.sync {
                self.rides = fetchedRides
            }
            
        } catch {
            print("getRides: NETWORK ERROR")
        }
    }

}

