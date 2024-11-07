import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0/255, green: 39/255, blue: 76/255)
                    .ignoresSafeArea()
                
                Text("Account View")
                    .foregroundColor(.yellow)
                    .font(.title)
            }
            .navigationBarTitle("Account", displayMode: .inline)
        }
    }
}
