import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var startLocation: String = ""
    @State private var endLocation: String = ""
    @State private var startCoordinate: CLLocationCoordinate2D? = nil
    @State private var endCoordinate: CLLocationCoordinate2D? = nil
    @State private var selectedTab: Int = 0
    @StateObject var savedPlaylistManager = SavedPlaylistManager()
    @StateObject var userManager = UserManager()
    
    var body: some View {
        Group {
            if userManager.isSignedIn {
                TabView(selection: $selectedTab) {
                    HomeView(startLocation: $startLocation,
                             endLocation: $endLocation,
                             startCoordinate: $startCoordinate,
                             endCoordinate: $endCoordinate,
                             selectedTab: $selectedTab)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    PlaylistView(startLocation: startLocation,
                                 endLocation: endLocation,
                                 startCoordinate: startCoordinate,
                                 endCoordinate: endCoordinate,
                                 selectedTab: $selectedTab)
                        .tabItem {
                            Label("Playlist", systemImage: "music.note.list")
                        }
                        .tag(1)
                    
                    AttractionsView(selectedTab: $selectedTab)
                        .tabItem {
                            Label("Attractions", systemImage: "map.fill")
                        }
                        .tag(2)
                    
                    AccountView()
                        .tabItem {
                            Label("Account", systemImage: "person.crop.circle")
                        }
                        .tag(3)
                }
                .tint(.white)
                .onAppear {
                    UITabBar.appearance().unselectedItemTintColor = UIColor.white
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(savedPlaylistManager)
        .environmentObject(userManager)
    }
}
