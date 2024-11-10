import Foundation
import Combine

class RideServicesViewModel: ObservableObject {
    @Published var services: [Service] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let baseURL = "http://35.2.2.224:5000"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchServices()
    }
    
    func fetchServices() {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "\(baseURL)/api/v1/settings/services/") else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ServiceResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                self?.services = response.services.map { $0.toDomainModel() }
            }
            .store(in: &cancellables)
    }
    
    
}
