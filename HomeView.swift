import SwiftUI
import MapKit
import CoreLocation

struct HomeView: View {
    @Binding var startLocation: String
    @Binding var endLocation: String
    @Binding var startCoordinate: CLLocationCoordinate2D?
    @Binding var endCoordinate: CLLocationCoordinate2D?
    @Binding var selectedTab: Int

    @State private var selectedPinTitle: String? = nil

    @State var generatedWaypoints: [Waypoint] = [
        Waypoint(coordinate: CLLocationCoordinate2D(latitude: 41.3083, longitude: -72.9279), title: "New Haven")
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Road Trip Playlist Builder")
                    .font(.custom("Milky Vintage", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                locationInput(title: "Start Point:", text: $startLocation)
                locationInput(title: "End Point:", text: $endLocation)

                HStack(spacing: 15) {
                    Button(action: generatePlaylist) {
                        Text("Generate Playlist")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }

                    Button(action: clearLocations) {
                        Text("Clear")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)

                MapView(startCoordinate: $startCoordinate,
                        endCoordinate: $endCoordinate,
                        selectedPinTitle: $selectedPinTitle,
                        waypoints: generatedWaypoints)
                    .frame(height: 300)
                    .cornerRadius(15)
                    .padding()

                Spacer()
            }
        }
        .alert(isPresented: .constant(selectedPinTitle != nil)) {
            Alert(
                title: Text(selectedPinTitle ?? ""),
                message: Text("Fetch music or attractions for this location?"),
                primaryButton: .default(Text("Music")) {
                    // TODO: Hook to Last.fm fetch if needed
                    selectedPinTitle = nil
                },
                secondaryButton: .default(Text("Attractions")) {
                    // TODO: Hook to Google Places fetch
                    selectedPinTitle = nil
                }
            )
        }
    }

    @ViewBuilder
    private func locationInput(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
            TextField("Enter location", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
        }
        .padding(.horizontal, 30)
    }

    private func clearLocations() {
        startLocation = ""
        endLocation = ""
        startCoordinate = nil
        endCoordinate = nil
        generatedWaypoints = []
    }

    func generatePlaylist() {
        let group = DispatchGroup()
        group.enter()
        getCoordinates(for: startLocation) { coordinate in
            DispatchQueue.main.async {
                startCoordinate = coordinate
                group.leave()
            }
        }
        group.enter()
        getCoordinates(for: endLocation) { coordinate in
            DispatchQueue.main.async {
                endCoordinate = coordinate
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let start = startCoordinate, let end = endCoordinate {
                generateWaypoints(from: start, to: end) { waypoints in
                    self.generatedWaypoints = waypoints
                    selectedTab = 1
                }
            }
        }
    }

    func generateWaypoints(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, completion: @escaping ([Waypoint]) -> Void) {
        completion([
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 41.3083, longitude: -72.9279), title: "New Haven")
        ])
    }
}
