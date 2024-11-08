import Foundation

@MainActor
class RideServicesViewModel: ObservableObject {
    @Published private(set) var services: [Service] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init() {
        // Initially load mock data
        loadMockServices()
    }
    
    private func loadMockServices() {
        services = [
            Service(
                provider: "RideHome",
                serviceName: "FreeRides",
                costUSD: 0.0,
                startTime: DateComponents(hour: 20, minute: 0),
                endTime: DateComponents(hour: 2, minute: 0),
                daysAvailable: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
            ),
            Service(
                provider: "GET!",
                serviceName: "RideShare",
                costUSD: 5.0,
                startTime: DateComponents(hour: 0, minute: 0),
                endTime: DateComponents(hour: 23, minute: 59),
                daysAvailable: DaysOfWeek.allDays
            )
        ]
    }
    
    func fetchServices() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: Replace with actual API call
            // let services = try await apiClient.fetchServices()
            // self.services = services
            
            // For now, just simulate API delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            loadMockServices()
        } catch {
            self.error = error
        }
    }
}
