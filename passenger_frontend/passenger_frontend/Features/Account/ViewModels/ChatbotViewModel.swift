import Foundation
import Combine
import CoreLocation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

class ChatbotViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage: String = ""
    @Published var isLoading: Bool = false
    
    private let welcomeMessage = "Hello! I'm SAFE's virtual assistant. How can I help you today? I can answer questions about booking rides, safety features, account management, as well as making/cancelling your bookings!"
    
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var currentLocation: CLLocationCoordinate2D?
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        messages.append(ChatMessage(content: welcomeMessage, isUser: false, timestamp: Date()))
        
        locationManager.$location
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)
    }
    
    func sendMessage() {
        print("📨 sendMessage() called") // Debug function entry
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { 
            print("❌ Empty message, returning") // Debug guard clause
            return 
        }
        
        let userMessage = inputMessage
        messages.append(ChatMessage(content: userMessage, isUser: true, timestamp: Date()))
        inputMessage = ""
        isLoading = true
        
        let messageHistory = messages.map { message in
            [
                "role": message.isUser ? "user" : "model",
                "content": message.content
            ]
        }
        
        guard let latitude = currentLocation?.latitude,
              let longitude = currentLocation?.longitude else {
            handleError("Location not available")
            isLoading = false
            return
        }
        
        let requestBody: [String: Any] = [
            "messages": messageHistory,
            "message": userMessage,
            "lat": latitude,
            "user": authViewModel.user?.id,
            "lon": longitude
        ]
        print("📤 Request Body:", requestBody) // Debug request payload
        
        guard let url = URL(string: "http://18.191.14.26/api/v1/chat/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Failed to create URL or serialize JSON") // Debug URL/JSON creation
            handleError("Failed to prepare request")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Network Error:", error) // Debug network errors
                    self?.handleError(error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 Response status code:", httpResponse.statusCode)
                    print("📥 Response headers:", httpResponse.allHeaderFields) // Debug response headers
                }
                
                guard let data = data else {
                    print("❌ No data received from server") // Debug empty response
                    self?.handleError("No data received")
                    return
                }
                
                print("📥 Raw response data:", String(data: data, encoding: .utf8) ?? "Unable to convert data to string") // Debug raw response
                
                do {
                    let response = try JSONDecoder().decode(ChatResponse.self, from: data)
                    print("📥 Decoded response:", response) // Debug decoded response
                    if response.success {
                        self?.messages.append(ChatMessage(content: response.response, isUser: false, timestamp: Date()))
                    } else {
                        self?.handleError(response.error ?? "Unknown error")
                    }
                } catch {
                    self?.handleError("Failed to decode response")
                }
            }
        }.resume()
    }
    
    private func handleError(_ message: String) {
        messages.append(ChatMessage(
            content: "Sorry, I encountered an error. Please try again later.",
            isUser: false,
            timestamp: Date()
        ))
        print("Error: \(message)")
    }
}

struct ChatResponse: Codable {
    let response: String
    let success: Bool
    let error: String?
}
