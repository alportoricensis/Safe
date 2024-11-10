import SwiftUI
import Combine

struct CurrRidesView: View {
    private let store = RideStore.shared
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            List(store.rides) { ride in
                RideList(ride: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red:0.2, green:0.2, blue:0.5))
            }
            .listStyle(.plain)
            .onAppear {
                Task {
                    await store.getRides()
                }
            }
            .onReceive(timer) { _ in
                Task {
                    await store.getRides()
                }
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    CurrRidesView()
}
