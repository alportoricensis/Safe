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
        self.rides = [
        Ride(
                    pickupLoc: "Duderstadt Center",
                    dropLoc: "South Quad",
                    passenger: "John Doe",
                    status: "Pending",
                    id: "ride1",
                    pickupLatitude: 42.2936,
                    pickupLongitude: -83.7166,
                    dropOffLatitude: 42.2745,
                    dropOffLongitude: -83.7409
                ),
                Ride(
                    pickupLoc: "Michigan Union",
                    dropLoc: "North Campus",
                    passenger: "Jane Smith",
                    status: "In-Progress",
                    id: "ride2",
                    pickupLatitude: 42.2765,
                    pickupLongitude: -83.7412,
                    dropOffLatitude: 42.2918,
                    dropOffLongitude: -83.7175
                ),
                Ride(
                    pickupLoc: "Hill Auditorium",
                    dropLoc: "Ross School of Business",
                    passenger: "Alice Johnson",
                    status: "Completed",
                    id: "ride3",
                    pickupLatitude: 42.278043,
                    pickupLongitude: -83.738224,
                    dropOffLatitude: 42.274597,
                    dropOffLongitude: -83.735439
                ),
                Ride(
                    pickupLoc: "Diag",
                    dropLoc: "Crisler Center",
                    passenger: "Bob Brown",
                    status: "Pending",
                    id: "ride4",
                    pickupLatitude: 42.2755,
                    pickupLongitude: -83.7382,
                    dropOffLatitude: 42.2650,
                    dropOffLongitude: -83.7486
                )
            ]
            return
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

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let rideOrder = jsonObj["rideOrder"] as? [String] else {
                print("getRides: JSON deserialization failed")
                synchronized.sync {
                    self.isRetrieving = false
                }
                return
            }

            var fetchedRides = [Ride]()
            for rideId in rideOrder {
                if let rideData = jsonObj[rideId] as? [String: Any] {
                    let pickup = rideData["pickup"] as? String ?? "Unknown"
                    let dropoff = rideData["dropoff"] as? String ?? "Unknown"
                    let passenger = rideData["passenger"] as? String ?? "Unknown"
                    let status = rideData["status"] as? String ?? "Pending"
                    let pickupLatitude = rideData["pickupLatitude"] as? Double ?? 0.0
                    let pickupLongitude = rideData["pickupLongitude"] as? Double ?? 0.0
                    let dropOffLatitude = rideData["dropoffLatitude"] as? Double ?? 0.0
                    let dropOffLongitude = rideData["dropoffLongitude"] as? Double ?? 0.0

                    fetchedRides.append(Ride(
                        pickupLoc: pickup,
                        dropLoc: dropoff,
                        passenger: passenger,
                        status: status,
                        id: rideId,
                        pickupLatitude: pickupLatitude,
                        pickupLongitude: pickupLongitude,
                        dropOffLatitude: dropOffLatitude,
                        dropOffLongitude: dropOffLongitude
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
            // Optionally, notify the backend about the status update
        }
    }
}
