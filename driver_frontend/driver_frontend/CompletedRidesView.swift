import SwiftUI
import Combine

struct CurrRidesView: View {
    @ObservedObject private var store = RideStore.shared
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            List(store.rides.filter { $0.status != "Completed" }) { ride in
                RideList(ride: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
            }
            .listStyle(.plain)
            .refreshable {
                await store.getRides()
            }
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


import SwiftUI

struct CompletedRidesView: View {
    @ObservedObject private var store = RideStore.shared // Ensure RideStore is ObservableObject

    var body: some View {
        VStack {
            List(store.rides.filter { $0.status == "Completed" }) { ride in
                RideList(ride: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
            }
            .listStyle(.plain)
            .refreshable {
                await store.getRides()
            }
            .onAppear {
                Task {
                    await store.getRides()
                }
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
    }
}

struct CompletedRidesView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedRidesView()
            .environmentObject(RideStore.shared)
    }
}
