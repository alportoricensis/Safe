import Foundation

enum DaysOfWeek: String, Codable, CaseIterable, Identifiable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: String { self.rawValue.capitalized }
    
    static var allDays: [DaysOfWeek] {
        return DaysOfWeek.allCases
    }
}
struct Service: Identifiable, Codable {
    let id: UUID
    let provider: String
    let serviceName: String
    let costUSD: Double
    let startTime: DateComponents
    let endTime: DateComponents
    let daysAvailable: [DaysOfWeek]
    init(
        provider: String,
        serviceName: String,
        costUSD: Double,
        startTime: DateComponents,
        endTime: DateComponents,
        daysAvailable: [DaysOfWeek]
    ) {
        self.id = UUID()
        self.provider = provider
        self.serviceName = serviceName
        self.costUSD = costUSD
        self.startTime = startTime
        self.endTime = endTime
        self.daysAvailable = daysAvailable
    }
}
