import SwiftUI
import Combine

struct TodaysRides: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var tdrides = [DriverRideHistory]()
    //@State private var vehicleId = authManager.vehicleID
    var body: some View {
        VStack {
            List(tdrides) { ride in
                RideHistoryList(hist: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
            }
            .listStyle(.plain)
            .onAppear {
                Task {
                    await getTodaysRides()
                }
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
    }
    
    func getTodaysRides() async {
        print("Inside getTodaysRides")
        guard let vehicleId = authManager.vehicleID else {
            print("getTodaysRides: Vehicle ID is not set.")
            return
        }

        guard let apiUrl = URL(string: "http://18.191.14.26/api/v1/vehicles/statistics/") else {
            print("getTodaysRides: Bad URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
            // Calculate start and end times for the current day
            let now = Date()
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: now)
            print(startOfDay)
            let startTime = Int(startOfDay.timeIntervalSince1970) // Start time as Unix timestamp
            let endTime = Int(now.timeIntervalSince1970) // Current time as Unix timestamp

            // Create the request body with vehicle_id, start_time, and end_time
            let parameters: [String: Any] = [
                "vehicle_id": vehicleId,
                "start_time": startTime,
                "end_time": endTime
            ]
            print(vehicleId)
            print(startTime)
            print(endTime)
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = requestData

            // Make the API call
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpStatus = response as? HTTPURLResponse {
                if httpStatus.statusCode != 200 {
                    print("getTodaysRides: HTTP STATUS: \(httpStatus.statusCode)")
                    return
                } else {
                    print("getTodaysRides: HTTP request was successful. STATUS: \(httpStatus.statusCode)")
                }
            }
            // Parse the JSON response
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                       print("getTodaysRides: JSON deserialization failed")
                       return
                   }

            var fetchedRides = [DriverRideHistory]()
            print(jsonObj)
//            for rideData in jsonObj {
//                if let rideId = UIUD() as? String {
//                    let miles = rideData.milesTravelled as? Double ?? 0.0
//                    let passengerCount = rideData.numPassengers as? Int ?? 0
//
//                    fetchedRides.append(DriverRideHistory(
//                        rideDate: String(endTime),
//                        passCount: String(passengerCount),
//                        miles: String(miles),
//                        id: rideId
//                    ))
//                }
//            }
            guard let numPassengers = jsonObj["numPassengers"] as? Int,
                  let milesTravelled = jsonObj["milesTravelled"] as? Double else {
                print("getTodaysRides: Missing required fields in JSON response")
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let today = dateFormatter.string(from: now)
            
            fetchedRides.append(DriverRideHistory(
                rideDate: today,
                passCount: String(numPassengers),
                miles: String(milesTravelled),
                id: UUID().uuidString
            ))
            DispatchQueue.main.async {
                self.tdrides = fetchedRides
            }
        } catch {
            print("getTodaysRides: NETWORK ERROR - \(error.localizedDescription)")
        }
    }
}

#Preview {
    TodaysRides()
}
