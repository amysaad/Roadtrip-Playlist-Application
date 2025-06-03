
import SwiftUI

struct SavedPlaylistDetailView: View {
    let playlist: SavedPlaylist
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(playlist.orderedWaypoints, id: \.self) { waypoint in
                    DisclosureGroup {
                        VStack(spacing: 15) {
                            if let tracks = playlist.groupedTracks[waypoint] {
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
        }
        .navigationTitle("\(playlist.startLocation) → \(playlist.endLocation) Playlist")
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
        )
    }
}
