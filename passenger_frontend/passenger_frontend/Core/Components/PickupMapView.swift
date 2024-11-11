import SwiftUI
import MapKit

class SearchCompleterObservable: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
    }
    
    func search(with query: String) {
        completer.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
}

struct PickupMapView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var mapRegion: MKCoordinateRegion
    @State private var searchText = ""
    @State private var isSearching = false
    
    @StateObject private var searchCompleter = SearchCompleterObservable()
    
    var onLocationSelected: (CLLocationCoordinate2D) -> Void
    
    init(onLocationSelected: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onLocationSelected = onLocationSelected
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapRegion, 
                interactionModes: [.all],
                showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .offset(y: -5)
            }
            .shadow(radius: 5)
            
            VStack(spacing: 0) {
                SearchBar(text: $searchText, isSearching: $isSearching)
                    .padding()
                
                if isSearching && !searchCompleter.searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(searchCompleter.searchResults, id: \.self) { result in
                                Button(action: {
                                    searchLocation(result)
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                            .foregroundColor(.primary)
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                            }
                        }
                        .background(Color(.systemBackground))
                    }
                    .frame(maxHeight: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        if let location = locationManager.location {
                            mapRegion.center = location
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding()
                }
                
                Button(action: {
                    onLocationSelected(mapRegion.center)
                    dismiss()
                }) {
                    Text("Confirm Pickup Location")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                        .padding()
                }
            }
        }
        .onAppear {
            if let location = locationManager.location {
                mapRegion.center = location
            }
        }
        .onChange(of: searchText) { newValue in
            if !newValue.isEmpty {
                searchCompleter.search(with: newValue)
                isSearching = true
            } else {
                isSearching = false
            }
        }
    }
    
    private func searchLocation(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            withAnimation {
                mapRegion = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                searchText = result.title
                isSearching = false
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search location", text: $text)
                    .onTapGesture {
                        isSearching = true
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
            
            if isSearching {
                Button("Cancel") {
                    text = ""
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil, from: nil, for: nil)
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing))
            }
        }
    }
}