import SwiftUI

struct RideShareView: View {
    @State private var pickupPoint: String = ""
    @State private var destination: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor(red: 0.06, green: 0.15, blue: 0.29, alpha: 1.0))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .imageScale(.large)
                        }
                        Spacer()
                        Text("SAFE!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.yellow)
                        Spacer()
                    }
                    .padding()
                    
                    // Search Fields
                    VStack(spacing: 16) {
                        TextField("Enter pickup point", text: $pickupPoint)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(8)
                        
                        TextField("Where to?", text: $destination)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 20) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                Text("Saved Places")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "mappin.circle")
                                    .foregroundColor(.white)
                                Text("Set location on map")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Bottom Navigation Bar
                    HStack(spacing: 40) {
                        NavigationLink(destination: Text("Services")) {
                            VStack {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Services")
                                    .font(.caption)
                            }
                            .foregroundColor(.yellow)
                        }
                        
                        NavigationLink(destination: Text("Bookings")) {
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Bookings")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        
                        NavigationLink(destination: Text("Account")) {
                            VStack {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Account")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct RideShareView_Previews: PreviewProvider {
    static var previews: some View {
        RideShareView()
    }
}
