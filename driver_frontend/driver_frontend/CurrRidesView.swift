import SwiftUI

struct CurrRidesView: View {
    private let store = RideStore.shared

    var body: some View {
        VStack {
            List(store.rides) { ride in
                RideList(ride: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red:0.2, green:0.2, blue:0.5)) 
            }
            .listStyle(.plain) 
            .onAppear {
                Task{
                    await store.getRides()
                }
                
            }
        }
        .background(Color(red: 0.2, green: 0.2, blue: 0.5))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    CurrRidesView()
}
