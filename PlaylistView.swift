import SwiftUI
import MapKit
import CoreLocation

struct PlaylistView: View {
    let startLocation: String
    let endLocation: String
    let startCoordinate: CLLocationCoordinate2D?
    let endCoordinate: CLLocationCoordinate2D?

    @State private var groupedTracks: [String: [LastFMTrack]] = [:]
    @State private var orderedWaypoints: [String] = []
    @State private var isLoading: Bool = true
    @State private var reloadKey = UUID()

    @Binding var selectedTab: Int
    @EnvironmentObject var savedPlaylistManager: SavedPlaylistManager
    @EnvironmentObject var userManager: UserManager

    @State private var selectedGenre: String = UserDefaults.standard.string(forKey: "SelectedGenre") ?? "pop"
    @State private var playlistMode: PlaylistMode = .locationOnly

    enum PlaylistMode: String, CaseIterable, Identifiable {
        case locationOnly = "Location-Based"
        case genreOnly = "Genre-Based"
        case hybrid = "Location + Genre"

        var id: String { self.rawValue }
    }

    let allGenres = ["pop", "rock", "hip hop", "electronic", "indie", "country", "jazz", "metal", "classical"]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack {
                    if isLoading {
                        ProgressView("Fetching playlist...")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            Button("Refresh Tracks") {
                                fetchTracksForWaypoints(waypoints: orderedWaypoints)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.8))
                            .cornerRadius(12)
                            .padding(.horizontal)

                            Button(action: {
                                selectedTab = 0
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Generate New Playlist")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.7))
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                            .padding()

                            Picker("Mode", selection: $playlistMode) {
                                ForEach(PlaylistMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()

                            if playlistMode != .locationOnly {
                                VStack(alignment: .leading) {
                                    Text("Select Genre:")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(allGenres, id: \.self) { genre in
                                                Text(genre.capitalized)
                                                    .font(.subheadline)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(selectedGenre == genre ? Color.blue : Color.white.opacity(0.3))
                                                    .foregroundColor(selectedGenre == genre ? .white : .black)
                                                    .cornerRadius(20)
                                                    .shadow(radius: selectedGenre == genre ? 4 : 0)
                                                    .onTapGesture {
                                                        selectedGenre = genre
                                                    }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }

                            // 🎵 Playlist Summary
                            let totalTracks = groupedTracks.values.flatMap { $0 }.count
                            let estimatedMinutes = Int(Double(totalTracks) * 3.5)

                            Text("🎶 \(totalTracks) Tracks • ⏱ ~\(estimatedMinutes) min")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                                .padding(.bottom, 5)

                            // 📀 Track List by Waypoint
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(orderedWaypoints, id: \.self) { waypoint in
                                    DisclosureGroup {
                                        VStack(spacing: 15) {
                                            if let tracks = groupedTracks[waypoint] {
                                                ForEach(tracks) { track in
                                                    LastFMTrackRow(track: track)
                                                }
                                            } else {
                                                Text("No tracks available.")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 10)
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(.red)
                                            Text(waypoint)
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                    }
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal)
                                }
                            }
                            .id(reloadKey)
                        }
                    }
                }
            }
            .navigationTitle("Your Playlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: downloadPlaylist) {
                        Text("Download")
                    }
                }
            }
            .onAppear {
                fetchRouteWaypointsAndTracks()
            }
        }
    }

    func getTagForLocation(_ location: String) -> String {
        let city = location.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? location
        let mapping: [String: String] = [
            "New York": "hip-hop",
            "Los Angeles": "rock",
            "Chicago": "blues",
            "Nashville": "country",
            "Miami": "latin",
            "Austin": "indie",
            "Bakersfield": "country",
            "San Francisco": "pop"
        ]
        return mapping[city] ?? "pop"
    }

    func downloadPlaylist() {
        guard userManager.isSignedIn else {
            print("User must sign in to download a playlist.")
            return
        }

        if !groupedTracks.isEmpty && !orderedWaypoints.isEmpty {
            let saved = SavedPlaylist(ownerEmail: userManager.email,
                                      startLocation: startLocation,
                                      endLocation: endLocation,
                                      groupedTracks: groupedTracks,
                                      orderedWaypoints: orderedWaypoints)
            savedPlaylistManager.savedPlaylists.append(saved)
            print("Playlist downloaded and saved for \(userManager.email).")
        } else {
            print("Nothing to save yet.")
        }
    }

    func fetchRouteWaypointsAndTracks() {
        guard let startCoord = startCoordinate, let endCoord = endCoordinate else {
            print("Start or end coordinates are missing.")
            isLoading = false
            return
        }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoord))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoord))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Error calculating directions: \(error)")
                self.isLoading = false
                return
            }

            guard let route = response?.routes.first else {
                print("No route found.")
                self.isLoading = false
                return
            }

            let steps = route.steps.filter { !$0.instructions.isEmpty }
            var waypointLabels: [String?] = Array(repeating: nil, count: steps.count)
            let geoGroup = DispatchGroup()

            for (index, step) in steps.enumerated() {
                let coordinate = step.polyline.coordinate
                geoGroup.enter()
                reverseGeocode(coordinate: coordinate) { formattedLocation in
                    waypointLabels[index] = formattedLocation
                    geoGroup.leave()
                }
            }

            geoGroup.notify(queue: .main) {
                let orderedWaypointsFull = waypointLabels.compactMap { $0 }
                var uniqueOrderedWaypoints: [String] = []
                for waypoint in orderedWaypointsFull {
                    if uniqueOrderedWaypoints.last != waypoint {
                        uniqueOrderedWaypoints.append(waypoint)
                    }
                }

                if let first = uniqueOrderedWaypoints.first, !first.lowercased().contains(startLocation.lowercased()) {
                    uniqueOrderedWaypoints.insert(startLocation, at: 0)
                }
                if let last = uniqueOrderedWaypoints.last, !last.lowercased().contains(endLocation.lowercased()) {
                    uniqueOrderedWaypoints.append(endLocation)
                }

                self.orderedWaypoints = uniqueOrderedWaypoints
                self.fetchTracksForWaypoints(waypoints: uniqueOrderedWaypoints)
            }
        }
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(loc) { placemarks, error in
            if let placemark = placemarks?.first {
                if let city = placemark.locality, let state = placemark.administrativeArea {
                    completion("\(city), \(state)")
                } else if let city = placemark.locality {
                    completion(city)
                } else if let state = placemark.administrativeArea {
                    completion(state)
                } else {
                    completion(placemark.name)
                }
            } else {
                completion(nil)
            }
        }
    }

    func fetchTracksForWaypoints(waypoints: [String]) {
        self.groupedTracks = [:]
        self.reloadKey = UUID()
        self.isLoading = true

        var results: [String: [LastFMTrack]] = [:]
        let group = DispatchGroup()

        for waypoint in waypoints {
            group.enter()

            let tag: String
            switch playlistMode {
            case .locationOnly:
                tag = getTagForLocation(waypoint)
            case .genreOnly:
                tag = selectedGenre
            case .hybrid:
                tag = "\(getTagForLocation(waypoint))+\(selectedGenre)"
            }

            LastFMService.shared.fetchTopTracks(forTag: tag) { tracks in
                let uniqueTracks = Dictionary(grouping: tracks, by: { $0.id })
                    .compactMap { $0.value.first }
                    .shuffled()
                    .prefix(7)
                results[waypoint] = Array(uniqueTracks)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.groupedTracks = results
            self.isLoading = false
        }
    }
}
