
import SwiftUI
import Combine

struct PreviousWeekRides: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var prevWeekRides = [DriverRideHistory]()
    
    var body: some View {
        VStack {
            List(prevWeekRides) { ride in
                RideHistoryList(hist: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
            }
            .listStyle(.plain)
            .onAppear {
                Task {
                    await getPrevStats()
                }
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
    }
    
    func getPrevStats() async {
        print("Inside getPrevStats")
        guard let vehicleId = authManager.vehicleID else {
            print("getPrevStats: Vehicle ID is not set.")
            return
        }

        guard let apiUrl = URL(string: "http://18.191.14.26/api/v1/vehicles/statistics/") else {
            print("getPrevStats: Bad URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
            let now = Date()
            let calendar = Calendar.current
            let startOfWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: calendar.startOfDay(for: now))!

            
            //do prev week stuff
            for i in 0..<7 {
                let dayStart = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
                let dayEnd = calendar.date(byAdding: .day, value: i, to: dayStart)!
                
                let startTime = Int(dayStart.timeIntervalSince1970)
                let endTime = Int(dayEnd.timeIntervalSince1970)
                
                await getStats(vehicleId: vehicleId, startTime: startTime, endTime: endTime, request: request)
            }
        } 
    }
    
    func getStats(vehicleId: String, startTime: Int, endTime: Int, request: URLRequest) async {
        var requestCopy = request
        do {
            let parameters: [String: Any] = [
                "vehicle_id": vehicleId,
                "start_time": startTime,
                "end_time": endTime
            ]
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            requestCopy.httpBody = requestData

            // Make the API call
            let (data, response) = try await URLSession.shared.data(for: requestCopy)

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getStats: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("getStats: JSON deserialization failed")
                return
            }

            guard let numPassengers = jsonObj["numPassengers"] as? Int,
                  let milesTravelled = jsonObj["milesTravelled"] as? Double else {
                print("getStats: Missing required fields in JSON response")
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = Date(timeIntervalSince1970: TimeInterval(startTime))
            let rideDate = dateFormatter.string(from: date)
            
            DispatchQueue.main.async {
                self.prevWeekRides.append(DriverRideHistory(
                    rideDate: rideDate,
                    passCount: String(numPassengers),
                    miles: String(milesTravelled),
                    id: UUID().uuidString
                ))
            }
        } catch {
            print("getStats: NETWORK ERROR - \(error.localizedDescription)")
        }
    }
}

#Preview {
    PreviousWeekRides()
}
