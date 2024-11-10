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
    
    private let welcomeMessage = "Hello! I'm SAFE's virtual assistant. How can I help you today? I can answer questions about booking rides, safety features, account management, and more."
    
    init() {
        // Add welcome message
        messages.append(ChatMessage(content: welcomeMessage, isUser: false, timestamp: Date()))
    }
    
    func sendMessage() {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = inputMessage
        messages.append(ChatMessage(content: userMessage, isUser: true, timestamp: Date()))
        inputMessage = ""
        isLoading = true
        
        // Prepare chat history
        let messageHistory = messages.map { message in
            [
                "role": message.isUser ? "user" : "model",
                "content": message.content
            ]
        }
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "messages": messageHistory,
            "message": userMessage
        ]
        
        // Print request body
        print("📤 Sending request with body:", requestBody)
        
        guard let url = URL(string: "http://35.2.2.224:5000/api/v1/chat/"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Failed to create URL or serialize JSON")
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
                    print("❌ Network error:", error.localizedDescription)
                    self?.handleError(error.localizedDescription)
                    return
                }
                
                // Print response status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 Response status code:", httpResponse.statusCode)
                }
                
                guard let data = data else {
                    print("❌ No data received from server")
                    self?.handleError("No data received")
                    return
                }
                
                // Print raw response data
                print("📥 Raw response:", String(data: data, encoding: .utf8) ?? "Unable to convert data to string")
                
                do {
                    let response = try JSONDecoder().decode(ChatResponse.self, from: data)
                    print("📥 Decoded response:", response)
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
