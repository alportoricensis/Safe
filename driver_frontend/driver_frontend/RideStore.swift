import Foundation
import Combine

class RideStore: ObservableObject {
    static let shared = RideStore()
    private init() {}

    @Published private(set) var rides = [Ride]()
    @Published var isRetrieving = false 
    private let synchronized = DispatchQueue(label: "synchronized", qos: .background)

    var username = ""
    var password = ""
    var vehicleId: String?
    var latitude: Double?
    var longitude: Double?

    private let serverUrl = "http://18.191.14.26/api/v1/rides/drivers/"

    func getRides() async {
//        self.rides = [
//                   Ride(pickupLoc: "123 Main St, Springfield", dropLoc: "456 Elm St, Springfield", passenger: "John Doe", status: "Pending", id: "ride1"),
//                   Ride(pickupLoc: "789 Oak St, Springfield", dropLoc: "321 Pine St, Springfield", passenger: "Jane Smith", status: "In-Progress", id: "ride2"),
//                   Ride(pickupLoc: "654 Maple St, Springfield", dropLoc: "987 Cedar St, Springfield", passenger: "Alice Johnson", status: "Completed", id: "ride3"),
//                   Ride(pickupLoc: "111 Birch St, Springfield", dropLoc: "222 Walnut St, Springfield", passenger: "Bob Brown", status: "Pending", id: "ride4")
//               ]
//        return
        guard let vehicleId = vehicleId else {
            print("getRides: Vehicle ID is not set.")
            return
        }

        synchronized.sync {
            guard !self.isRetrieving else { return }
            self.isRetrieving = true
        }

        guard let apiUrl = URL(string: "\(serverUrl)\(vehicleId)/") else {
            print("getRides: Bad URL")
            synchronized.sync {
                self.isRetrieving = false
            }
            return
        }

        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getRides: HTTP STATUS: \(httpStatus.statusCode)")
                synchronized.sync {
                    self.isRetrieving = false
                }
                return
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("getRides: JSON deserialization failed")
                synchronized.sync {
                    self.isRetrieving = false
                }
                return
            }

            var fetchedRides = [Ride]()
            for rideData in jsonObj {
                if let rideId = rideData["id"] as? String {
                    let pickup = rideData["pickup"] as? String ?? "Unknown"
                    let dropoff = rideData["dropoff"] as? String ?? "Unknown"
                    let passenger = rideData["passenger"] as? String ?? "Unknown"
                    let status = rideData["status"] as? String ?? "Pending"

                    fetchedRides.append(Ride(
                        pickupLoc: pickup,
                        dropLoc: dropoff,
                        passenger: passenger,
                        status: status,
                        id: rideId
                    ))
                }
            }

            DispatchQueue.main.async {
                self.rides = fetchedRides
                self.isRetrieving = false
            }

        } catch {
            print("getRides: NETWORK ERROR - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isRetrieving = false
            }
        }
    }

    func updateRideStatus(rideId: String, status: String) {
        if let index = rides.firstIndex(where: { $0.id == rideId }) {
            rides[index].status = status
            // Optionally, you can notify the backend about the status update here
        }
    }
}
