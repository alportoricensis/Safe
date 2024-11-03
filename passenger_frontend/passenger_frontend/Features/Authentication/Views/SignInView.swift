import SwiftUI

struct SignInView: View {
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
                    Button(action: {
                    }) {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            
                            Text("Sign in with Google")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    
                    NavigationLink(destination: RideServicesView(), isActive: $navigateToServices) {
                        EmptyView()
                    }
                    
                    Button(action: {
                        navigateToServices = true
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SAFE!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

