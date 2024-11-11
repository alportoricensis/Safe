import Foundation
import CoreLocation

class BookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    
    func fetchBookings() {
        isLoading = true
        guard let baseURL = URL(string: "http://35.2.2.224:5000/api/v1/users/bookings"),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "uuid", value: "102278719561247952889")
        ]
        
        guard let url = components.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
            }
            
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data else {
                    return
                }
                
                print("📦 Received data: \(String(data: data, encoding: .utf8) ?? "Unable to convert to string")")
                
                do {
                    let response = try JSONDecoder().decode(BookingsResponse.self, from: data)
                    self?.bookings = response.requests
                } catch {
                    print("Decoding error: \(error)")
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
