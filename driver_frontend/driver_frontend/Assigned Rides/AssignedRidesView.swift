import SwiftUI

struct AssignedRidesView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var selectedTab: RideTab = .current
    
    enum RideTab: String, CaseIterable {
        case current = "Current Rides"
        case completed = "Completed Rides"
    }
    
    var body: some View {
        VStack {
            // Header Section
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "car.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading) {
                        Text("Assigned Rides")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        

                    }
                }
            }
            .padding()
            .background(Color(red: 2/255, green: 28/255, blue: 52/255))
            .cornerRadius(10)
            
            // Segmented Control for Tabs
            Picker("Rides", selection: $selectedTab) {
                ForEach(RideTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(red: 2/255, green: 28/255, blue: 52/255))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Rides List
            if selectedTab == .current {
                CurrRidesView()
                    .environmentObject(store)
                    .environmentObject(locationManager)
            } else {
                CompletedRidesView()
                    .environmentObject(store)
            }
            
            Spacer()
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255).edgesIgnoringSafeArea(.all))
        .onAppear {
            Task {
                await store.getRides()
//                print("Rides loaded: \(store.rides)")
            }
        }
    }
}

struct AssignedRidesView_Previews: PreviewProvider {
    static var previews: some View {
        AssignedRidesView()
            .environmentObject(RideStore.shared)
            .environmentObject(LocationManager())
            .environmentObject(AuthManager())
    }
}
