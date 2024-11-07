import SwiftUI

struct RideServicesView: View {
    // Sample services data
    private let services: [Service] = [
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
    
    var body: some View {
        NavigationView {
            List(services) { service in
                ServiceCardView(service: service)
                    .padding(.vertical, 8)
            }
            .navigationTitle("Ride Services")
        }
    }
}



struct ServiceCardView: View {
    let service: Service
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(service.provider), \(service.serviceName)")
                .font(.system(size: 24, weight: .bold))
            
            Text(service.costUSD == 0 ? "Free" : "$\(String(format: "%.0f", service.costUSD))")
                .font(.system(size: 20))
            
            Text("\(service.startTime.hour ?? 0):\(String(format: "%02d", service.startTime.minute ?? 0)) - \(service.endTime.hour ?? 0):\(String(format: "%02d", service.endTime.minute ?? 0))")
                .font(.system(size: 20))
            
            Text(service.daysAvailable.count == 7 ? "24/7" : "7D/W")
                .font(.system(size: 20))
            
            Text("Available")
                .foregroundColor(.green)
                .font(.system(size: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow)
        .cornerRadius(8)
    }
}
