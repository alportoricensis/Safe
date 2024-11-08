import SwiftUI

struct RideServicesView: View {
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
                    .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
            }
            .background(Color(red: 0/255, green: 39/255, blue: 76/255))
            .scrollContentBackground(.hidden)
        }
        .navigationViewStyle(.stack)
        .withSafeTopBar()
    }
}

struct ServiceCardView: View {
    let service: Service
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(service.provider), \(service.serviceName)")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(service.costUSD == 0 ? "Free" : "$\(String(format: "%.0f", service.costUSD))")
                .font(.subheadline)
            
            Text("\(service.startTime.hour ?? 0):\(String(format: "%02d", service.startTime.minute ?? 0)) - \(service.endTime.hour ?? 0):\(String(format: "%02d", service.endTime.minute ?? 0))")
                .font(.subheadline)
            
            Text(service.daysAvailable.count == 7 ? "24/7" : "7D/W")
                .font(.subheadline)
            
            Text("Available")
                .foregroundColor(.green)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 255/255, green: 203/255, blue: 5/255))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
