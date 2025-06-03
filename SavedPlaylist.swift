
import Foundation

struct SavedPlaylist: Identifiable, Codable {
    let id: UUID
    let createdDate: Date
    let ownerEmail: String
    let startLocation: String
    let endLocation: String
    let groupedTracks: [String: [LastFMTrack]]
    let orderedWaypoints: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdDate
        case ownerEmail
        case startLocation
        case endLocation
        case groupedTracks
        case orderedWaypoints
    }
    
    init(ownerEmail: String, startLocation: String, endLocation: String,
         groupedTracks: [String: [LastFMTrack]], orderedWaypoints: [String]) {
        self.id = UUID()
        self.createdDate = Date()
        self.ownerEmail = ownerEmail
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.groupedTracks = groupedTracks
        self.orderedWaypoints = orderedWaypoints
    }
    
    // Custom init from decoder if needed
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        ownerEmail = try container.decode(String.self, forKey: .ownerEmail)
        startLocation = try container.decode(String.self, forKey: .startLocation)
        endLocation = try container.decode(String.self, forKey: .endLocation)
        groupedTracks = try container.decode([String: [LastFMTrack]].self, forKey: .groupedTracks)
        orderedWaypoints = try container.decode([String].self, forKey: .orderedWaypoints)
    }
    
    // Custom encode method if needed
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(ownerEmail, forKey: .ownerEmail)
        try container.encode(startLocation, forKey: .startLocation)
        try container.encode(endLocation, forKey: .endLocation)
        try container.encode(groupedTracks, forKey: .groupedTracks)
        try container.encode(orderedWaypoints, forKey: .orderedWaypoints)
    }
}


class SavedPlaylistManager: ObservableObject {
    @Published var savedPlaylists: [SavedPlaylist] = [] {
        didSet {
            LocalStorage.shared.savePlaylists(savedPlaylists)
        }
    }
    
    init() {
        self.savedPlaylists = LocalStorage.shared.loadPlaylists()
    }
}

