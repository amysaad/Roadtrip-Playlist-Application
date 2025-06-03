import Foundation

struct ITunesSearchResult: Codable {
let resultCount: Int
let results: [ITunesTrack]
}

struct ITunesTrack: Codable {
let previewUrl: String?
let trackName: String?
let artistName: String?
let artworkUrl100: String? // New field for album artwork.
}

class ITunesService {
    static let shared = ITunesService()
    
    func fetchArtwork(for track: LastFMTrack, completion: @escaping (String?) -> Void) {
        let searchTerm = "\(track.name) \(track.artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(searchTerm)&entity=song"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ITunesSearchResult.self, from: data)
                    // Use the first result’s artwork URL if available.
                    let artwork = result.results.first?.artworkUrl100
                    DispatchQueue.main.async {
                        completion(artwork)
                    }
                } catch {
                    print("Error decoding iTunes response: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
