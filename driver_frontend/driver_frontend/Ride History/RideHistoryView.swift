import SwiftUI
struct RideHistoryView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedTab: Tab = .today
    
    enum Tab {
        case today, previous
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    VStack {
                        
                        Text("Ride History")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            HistoryTabButton(text: "Today", isSelected: selectedTab == .today) {
                                selectedTab = .today
                            }
                            HistoryTabButton(text: "Previous Shifts", isSelected: selectedTab == .previous) {
                                selectedTab = .previous
                            }
                        }
                        .background(Color(red: 2/255, green: 28/255, blue: 52/255))
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.25)
                    .background(Color(red: 2/255, green: 28/255, blue: 52/255))
                    
                    VStack {
                        if selectedTab == .today {
                            TodaysRides().environmentObject(authManager)
                        } else {
                            Text("Completed Rides")
                                .font(.title)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color(red: 0/255, green: 39/255, blue: 76/255))
                }
                .edgesIgnoringSafeArea(.all)
                .withSafeTopBar()
            }
            .navigationBarTitle("Assigned Rides", displayMode: .inline) // Add navigation title
        }
    }
}
struct HistoryTabButton: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(isSelected ? .bold : .regular)
                    .padding(.vertical, 3)
                Rectangle()
                    .fill(isSelected ? Color.yellow : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
#Preview {
    RideHistoryView()
        .environmentObject(AuthManager())
        .environmentObject(LocationManager())
}
