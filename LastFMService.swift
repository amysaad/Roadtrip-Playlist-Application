import Foundation

struct LastFMTrack: Identifiable, Codable {
    let id: String
    let name: String
    let artist: String
    let imageUrl: String
    let trackUrl: String
    let artistImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artist
        case imageUrl
        case trackUrl
        case artistImageUrl
    }
}

struct LastFMAPIResponse: Codable {
let tracks: TracksContainer
struct TracksContainer: Codable {
let track: [TrackItem]
}
struct TrackItem: Codable {
let name: String
let url: String
let artist: Artist
let image: [ImageItem]
struct Artist: Codable {
let name: String
}
struct ImageItem: Codable {
let text: String
let size: String
enum CodingKeys: String, CodingKey {
case text = "#text"
case size
}
}
}
}

class LastFMService {
    static let shared = LastFMService()
    private let apiKey = "4aa5d412be6ad493cb9c8d127f47f07e"
    
    func fetchTopTracks(forTag tag: String, completion: @escaping ([LastFMTrack]) -> Void) {
        // Randomize the page number to vary the pool of tracks.
        let randomPage = Int.random(in: 1...3)  // Adjust range as needed.
        
        guard let tagEncoded = tag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://ws.audioscrobbler.com/2.0/?method=tag.gettoptracks&tag=\(tagEncoded)&api_key=\(apiKey)&format=json&limit=50&page=\(randomPage)")
        else {
            print("Invalid URL for tag: \(tag)")
            completion([])
            return
        }
        
        print("Fetching tracks for tag: \(tag) from URL: \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("LastFM API error: \(error)")
            }
            var tracks: [LastFMTrack] = []
            if let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(LastFMAPIResponse.self, from: data)
                    print("Received \(apiResponse.tracks.track.count) tracks for tag: \(tag)")
                    tracks = apiResponse.tracks.track.compactMap { item in
                        var candidate = item.image.first(where: { $0.size == "extralarge" })?.text ??
                        item.image.first(where: { $0.size == "large" })?.text ??
                        item.image.first(where: { $0.size == "medium" })?.text ??
                        item.image.first(where: { $0.size == "small" })?.text ?? ""
                        
                        if candidate.hasPrefix("http://") {
                            candidate = candidate.replacingOccurrences(of: "http://", with: "https://")
                        }
                        
                        let finalImageUrl = candidate.isEmpty ? "https://via.placeholder.com/60" : candidate
                        let id = "\(item.name)-\(item.artist.name)".replacingOccurrences(of: " ", with: "-")
                        return LastFMTrack(id: id,
                                           name: item.name,
                                           artist: item.artist.name,
                                           imageUrl: finalImageUrl,
                                           trackUrl: item.url,
                                           artistImageUrl: nil)
                    }
                } catch {
                    print("Error decoding Last.fm response: \(error)")
                }
            }
            DispatchQueue.main.async {
                completion(tracks)
            }
        }.resume()
    }
}
