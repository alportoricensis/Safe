import Foundation

struct ServiceResponse: Codable {
    let services: [APIService]
}

struct APIService: Codable {
    let cost: String
    let endTime: String
    let provider: String
    let serviceName: String
    let startTime: String
    
    func toDomainModel() -> Service {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let startComponents = dateFormatter.date(from: startTime)?.dateComponents
        let endComponents = dateFormatter.date(from: endTime)?.dateComponents
        
        return Service(
            provider: provider,
            serviceName: serviceName,
            costUSD: Double(cost) ?? 0.0,
            startTime: startComponents ?? DateComponents(),
            endTime: endComponents ?? DateComponents(),
            daysAvailable: DaysOfWeek.allDays
        )
    }
}

private extension Date {
    var dateComponents: DateComponents {
        Calendar.current.dateComponents([.hour, .minute], from: self)
    }
}