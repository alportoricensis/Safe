import SwiftUI

struct BookingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0/255, green: 39/255, blue: 76/255)
                    .ignoresSafeArea()
                
                Text("Bookings View")
                    .foregroundColor(.yellow)
                    .font(.title)
            }
            .navigationBarTitle("My Bookings", displayMode: .inline)
        }
    }
}
