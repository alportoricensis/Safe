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
            ZStack {
                Color(red: 0/255, green: 39/255, blue: 76/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(services) { service in
                                NavigationLink(destination: RideShareView()) {
                                    ServiceCardView(service: service)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Bottom Navigation Bar
                    HStack(spacing: 40) {
                        NavigationLink(destination: Text("Services")) {
                            VStack {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Services")
                                    .font(.caption)
                            }
                            .foregroundColor(.yellow)
                        }
                        
                        NavigationLink(destination: Text("Bookings")) {
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Bookings")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        
                        NavigationLink(destination: Text("Account")) {
                            VStack {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Account")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("SAFE!", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SAFE!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RideServicesView_Previews: PreviewProvider {
    static var previews: some View {
        RideServicesView()
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
