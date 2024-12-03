import SwiftUI

struct RideList: View {
    let ride: Ride
    
    var body: some View {
        RideCardView(ride: ride)
    }
}

struct RideList_Previews: PreviewProvider {
    static var previews: some View {
        RideList(ride: Ride(
            pickupLoc: "Duderstadt Center",
            dropLoc: "South Quad",
            passenger: "John Doe",
            status: "Pending",
            id: "ride1",
            pickupLatitude: 42.2936,
            pickupLongitude: -83.7166,
            dropOffLatitude: 42.2745,
            dropOffLongitude: -83.7409
        ))
        .previewLayout(.sizeThatFits)
    }
}
