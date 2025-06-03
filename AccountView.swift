import SwiftUI

struct AccountView: View {
    @EnvironmentObject var savedPlaylistManager: SavedPlaylistManager
    @EnvironmentObject var userManager: UserManager
    
    // Filter playlists based on the current user’s email.
    var userPlaylists: [SavedPlaylist] {
        savedPlaylistManager.savedPlaylists.filter { $0.ownerEmail == userManager.email }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Account Page")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                    if userPlaylists.isEmpty {
                        Text("No playlists downloaded yet.")
                            .foregroundColor(.white)
                    } else {
                        List {
                            ForEach(userPlaylists) { playlist in
                                NavigationLink(destination: SavedPlaylistDetailView(playlist: playlist)) {
                                    Text("\(playlist.startLocation) → \(playlist.endLocation) Playlist")
                                        .foregroundColor(.white)
                                }
                                .listRowBackground(Color.black.opacity(0.3))
                            }
                            .onDelete(perform: deletePlaylist)
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Saved Playlists")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func deletePlaylist(at offsets: IndexSet) {
        // Remove only from the user’s playlists.
        let playlistsToKeep = savedPlaylistManager.savedPlaylists.filter { $0.ownerEmail != userManager.email }
        let playlistsToDelete = userPlaylists
        var newPlaylists = playlistsToKeep
        for offset in offsets {
            let playlist = playlistsToDelete[offset]
            newPlaylists.append(contentsOf: savedPlaylistManager.savedPlaylists.filter { $0.id == playlist.id })
        }
        // In a simple implementation, we'll remove the selected items directly.
        savedPlaylistManager.savedPlaylists.removeAll { playlist in
            userPlaylists.enumerated().contains { index, userPlaylist in
                offsets.contains(index) && playlist.id == userPlaylist.id
            }
        }
    }
}
