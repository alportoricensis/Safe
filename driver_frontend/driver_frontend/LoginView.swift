import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Please Sign In")
                .font(.largeTitle)
            TextField("Username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
            Button(action: {
                authViewModel.login(username: username, password: password)
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
