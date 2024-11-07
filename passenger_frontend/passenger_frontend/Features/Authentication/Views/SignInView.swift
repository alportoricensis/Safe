import SwiftUI
import GoogleSignInSwift
struct SignInView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var navigateToServices = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0/255, green: 39/255, blue: 76/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 20) {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.yellow)
                            .accessibility(label: Text("Car Icon"))
                        
                        Text("Get there safely, every ride, every time")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 40)
                    
                    GoogleSignInButton(action: {
                        authViewModel.signInWithGoogle()
                    })
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                    Button(action: {
                        authViewModel.isAuthenticated = true
                    }) {
                        Text("Continue as guest")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                    }

                    
                    Spacer()
                    
                    Text("By continuing, you agree to our Terms and Conditions and Privacy Policy.")
                        .font(.footnote)
                        .foregroundColor(Color.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("SAFE!")

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

