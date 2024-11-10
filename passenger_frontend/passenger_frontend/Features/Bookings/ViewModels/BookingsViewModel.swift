import Foundation
import CoreLocation

class BookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    
    func fetchBookings() {
        isLoading = true
        print("📱 Starting fetchBookings()")
        
        guard let baseURL = URL(string: "http://35.2.2.224:5000/api/v1/users/bookings"),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            print("❌ Invalid URL")
            return 
        }
        
        components.queryItems = [
            URLQueryItem(name: "uuid", value: "102278719561247952889")
        ]
        
        guard let url = components.url else {
            print("❌ Failed to construct URL with query parameters")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status code: \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data else {
                    print("❌ No data received")
                    return 
                }
                
                print("📦 Received data: \(String(data: data, encoding: .utf8) ?? "Unable to convert to string")")
                
                do {
                    let response = try JSONDecoder().decode(BookingsResponse.self, from: data)
                    print("✅ Successfully decoded \(response.requests.count) bookings")
                    self?.bookings = response.requests
                } catch {
                    print("❌ Decoding error: \(error)")
                    print("❌ Debug description: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func deleteBooking(_ booking: Booking) {
        // Implement delete API call here
        // After successful deletion, remove from bookings array:
        bookings.removeAll { $0.id == booking.id }
    }
    
    func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Geocoding error: \(error)")
                    completion("\(latitude), \(longitude)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let address = [
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea
                    ].compactMap { $0 }.joined(separator: ", ")
                    
                    completion(address.isEmpty ? "\(latitude), \(longitude)" : address)
                } else {
                    completion("\(latitude), \(longitude)")
                }
            }
        }
    }
}
