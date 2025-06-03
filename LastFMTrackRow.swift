import SwiftUI

struct LastFMTrackRow: View {
    let track: LastFMTrack
    @State private var showWebPlayer = false
    @State private var artworkUrl: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: URL(string: artworkUrl ?? track.imageUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 5)

                VStack(alignment: .leading) {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Button {
                    showWebPlayer = true
                } label: {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $showWebPlayer) {
                    NavigationView {
                        if let url = URL(string: track.trackUrl) {
                            LastFMWebPlayerView(url: url)
                                .navigationBarTitle(Text(track.name), displayMode: .inline)
                                .navigationBarItems(leading: Button("Close") {
                                    showWebPlayer = false
                                })
                        } else {
                            Text("Invalid track URL")
                        }
                    }
                }
            }

            // 🎧 Apple Music & Spotify Buttons
            HStack(spacing: 16) {
                Button(action: {
                    let query = "\(track.name) \(track.artist)"
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://music.apple.com/us/search?term=\(query)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "music.note")
                        Text("Apple Music")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                }

                Button(action: {
                    let query = "\(track.name) \(track.artist)"
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://open.spotify.com/search/\(query)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                        Text("Spotify")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                }
            }
            .padding(.leading, 4)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .shadow(radius: 3)
        .onAppear {
            ITunesService.shared.fetchArtwork(for: track) { art in
                if let art = art {
                    self.artworkUrl = art
                }
            }
        }
    }
}
