import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .current // Default selected tab
    
    enum Tab {
        case current, completed
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top third with dark navy blue background
                VStack {
                    Text("Assigned Rides")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    Spacer() // Pushes the tabs to the bottom
                    
                    // Tab Headers at the bottom of the dark navy section
                    HStack(spacing: 0) {
                        TabButton(text: "Completed", isSelected: selectedTab == .completed) {
                            selectedTab = .completed
                        }
                        TabButton(text: "Current", isSelected: selectedTab == .current) {
                            selectedTab = .current
                        }
                    }
                    .background(Color(red: 0.1, green: 0.1, blue: 0.3))
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.25)
                .background(Color(red: 0.1, green: 0.1, blue: 0.3))
                
                // Bottom two-thirds with lighter navy blue background
                VStack {
                    // Content for each tab
                    if selectedTab == .current {
                        // Display current rides
                        CurrRidesView()
                    } else {
                        // Display completed rides
                        Text("Completed Rides")
                            .font(.title)
                            .padding()
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color(red: 0.2, green: 0.2, blue: 0.5))
            }
            .edgesIgnoringSafeArea(.all) // Ensures the colors reach screen edges
        }
    }
}

// Custom button for tabs with a yellow underline when selected
struct TabButton: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(isSelected ? .bold : .regular)
                    .padding(.vertical, 3)
                
                // Yellow underline when selected
                Rectangle()
                    .fill(isSelected ? Color.yellow : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
