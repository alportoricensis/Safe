import SwiftUI

struct RideHistoryView: View {
    var body: some View {
        Text("Ride History")
            .font(.largeTitle)
            .foregroundColor(.white)
            .background(Color(red: 0/255, green: 39/255, blue: 76/255))
            .navigationBarTitle("Ride History", displayMode: .inline) // Add navigation title
    }
}


struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.largeTitle)
            .foregroundColor(.white)
            .background(Color(red: 0/255, green: 39/255, blue: 76/255))
            .navigationBarTitle("Settings", displayMode: .inline) // Add navigation title
    }
}


struct SupportView: View {
    var body: some View {
        Text("Support")
            .font(.largeTitle)
            .foregroundColor(.white)
            .background(Color(red: 0/255, green: 39/255, blue: 76/255))
    }
}

struct MessagesView: View {
    var body: some View {
        Text("Messages")
            .font(.largeTitle)
            .foregroundColor(.white)
            .background(Color(red: 0/255, green: 39/255, blue: 76/255))
    }
}


