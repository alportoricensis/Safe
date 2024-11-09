import SwiftUI

struct WaitingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RideRequestViewModel
    
    var body: some View {
        ZStack {
            Color(red: 0/255, green: 39/255, blue: 76/255)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressView()
                    .scaleEffect(2)
                    .tint(.yellow)
                
                Text("Finding your ride...")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Dismiss")
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 2/255, green: 28/255, blue: 52/255))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
    }
}
