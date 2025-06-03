//
//  LocalStorage.swift
//  RoadTripPlaylistBuilderr
//
//  Created by Amy Saad on 4/9/25.
//

// LocalStorage.swift
import Foundation

class LocalStorage {
    static let shared = LocalStorage()
    
    private let userKey = "savedUser"
    private let playlistsKey = "savedPlaylists"
    
    func saveUser(_ userData: UserData) {
        if let encoded = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    func loadUser() -> UserData? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let userData = try? JSONDecoder().decode(UserData.self, from: data) else {
            return nil
        }
        return userData
    }
    
    func savePlaylists(_ playlists: [SavedPlaylist]) {
        if let encoded = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(encoded, forKey: playlistsKey)
        }
    }
    
    func loadPlaylists() -> [SavedPlaylist] {
        guard let data = UserDefaults.standard.data(forKey: playlistsKey),
              let playlists = try? JSONDecoder().decode([SavedPlaylist].self, from: data) else {
            return []
        }
        return playlists
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
