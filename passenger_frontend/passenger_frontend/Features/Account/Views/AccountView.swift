import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0/255, green: 39/255, blue: 76/255)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    // Profile Section
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(authViewModel.user?.displayName ?? "No Name")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text(authViewModel.user?.email ?? "No Email")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Favorites Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Favorites")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Add Home")
                                Spacer()
                            }
                            .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "briefcase.fill")
                                Text("Add Work")
                                Spacer()
                            }
                            .foregroundColor(.white)
                        }
                    }
                    
                    // More Saved Places
                    Text("More Saved Places")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    // Privacy Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Privacy")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text("Manage the data you share with us")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    
                    // Support Section
                    NavigationLink(destination: ChatbotView()) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Support")
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Talk to a support chatbot to get help right away")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                    
                    // Sign Out Button
                    Button(action: {
                        Task {
                            await authViewModel.signOut()
                        }
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .withSafeTopBar()
            .navigationBarTitle("Account Settings", displayMode: .inline)
        }
    }
}
