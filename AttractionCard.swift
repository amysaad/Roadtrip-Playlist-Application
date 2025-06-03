import SwiftUI

struct AttractionCard: View {
    public let attraction: Attraction
    public let imageUrl: String
    @State private var showMapOptions = false

    public init(attraction: Attraction, imageUrl: String) {
        self.attraction = attraction
        self.imageUrl = imageUrl
    }

    var body: some View {
        Button(action: {
            showMapOptions = true
        }) {
            HStack {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)

                VStack(alignment: .leading) {
                    Text(attraction.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    if let vicinity = attraction.vicinity {
                        Text(vicinity)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    if let rating = attraction.rating {
                        Text("⭐ \(rating, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
            .shadow(radius: 3)
        }
        .confirmationDialog("Open in Maps", isPresented: $showMapOptions, titleVisibility: .visible) {
            Button("Open in Apple Maps") {
                openInMaps(useGoogleMaps: false)
            }
            Button("Open in Google Maps") {
                openInMaps(useGoogleMaps: true)
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private func openInMaps(useGoogleMaps: Bool) {
        guard let lat = attraction.geometry.location.lat as Double?,
              let lng = attraction.geometry.location.lng as Double? else {
            print("Missing coordinates.")
            return
        }

        let query = "\(lat),\(lng)"
        let label = attraction.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if useGoogleMaps,
           let googleURL = URL(string: "comgooglemaps://?daddr=\(query)&q=\(label)"),
           UIApplication.shared.canOpenURL(googleURL) {
            UIApplication.shared.open(googleURL)
        } else if let appleURL = URL(string: "http://maps.apple.com/?daddr=\(query)&q=\(label)") {
            UIApplication.shared.open(appleURL)
        }
    }
}
