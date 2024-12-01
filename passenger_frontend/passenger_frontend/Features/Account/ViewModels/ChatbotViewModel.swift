import Foundation
import Combine

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
    
    init() {
        messages.append(ChatMessage(content: welcomeMessage, isUser: false, timestamp: Date()))
    }
    
    func sendMessage() {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
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
        
        let requestBody: [String: Any] = [
            "messages": messageHistory,
            "message": userMessage
        ]
        
        guard let url = URL(string: "http://35.3.200.144:5000/api/v1/chat/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            handleError("Failed to prepare request")
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
                    self?.handleError(error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 Response status code:", httpResponse.statusCode)
                }
                
                guard let data = data else {
                    self?.handleError("No data received")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ChatResponse.self, from: data)
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
    }
}

struct ChatResponse: Codable {
    let response: String
    let success: Bool
    let error: String?
}
