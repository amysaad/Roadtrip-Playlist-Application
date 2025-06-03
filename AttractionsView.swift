import SwiftUI
import CoreLocation

struct AttractionsView: View {
    @Binding var selectedTab: Int // 👈 control tab switch (0 = Home)
    @State private var locationQuery: String = ""
    @State private var coordinate: CLLocationCoordinate2D? = nil
    @StateObject private var viewModel = AttractionsViewModel()

    var body: some View {
        ZStack {
            // 🌈 Matching Gradient Background
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 🔙 Back to Home Button
                HStack {
                    Button(action: {
                        selectedTab = 0 // 👈 goes back to ContentView
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back to Home")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                // 🔍 Search Input
                HStack {
                    TextField("Enter a city or location", text: $locationQuery)
                        .foregroundColor(.black) // 👈 make text visible
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                    Button("Search") {
                        geocodeLocation(query: locationQuery)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // 📍 Attraction Results
                if let _ = coordinate {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Searching...")
                            .foregroundColor(.white)
                        Spacer()
                    } else if viewModel.attractions.isEmpty {
                        Spacer()
                        Text("No attractions found.")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.attractions) { attraction in
                                    AttractionCard(attraction: attraction,
                                                   imageUrl: viewModel.getImageURL(for: attraction))
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                } else {
                    Spacer()
                    Text("Enter a location to find attractions.")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
            }
        }
    }

    // 📍 Convert location string into coordinates
    func geocodeLocation(query: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { placemarks, error in
            if let location = placemarks?.first?.location {
                DispatchQueue.main.async {
                    self.coordinate = location.coordinate
                    viewModel.fetchAttractions(for: location.coordinate)
                }
            }
        }
    }
}
