import Foundation
import CoreLocation

// 📍 Attraction Model matching Google Places API
struct Attraction: Identifiable, Codable {
    var id: String { place_id }
    let place_id: String
    let name: String
    let vicinity: String?
    let rating: Double?
    let photos: [Photo]?
    let geometry: Geometry

    // Extract photo reference from the first photo
    var photoReference: String? {
        return photos?.first?.photo_reference
    }
}

// 📸 Google Places Photo Model
struct Photo: Codable {
    let photo_reference: String
}

// 📌 Geometry Model (Contains Coordinates)
struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

// 📌 API Response Model
struct PlacesResponse: Codable {
    let results: [Attraction]
}

// 🌍 ViewModel for Fetching Attractions
class AttractionsViewModel: ObservableObject {
    @Published var attractions: [Attraction] = []
    @Published var isLoading: Bool = false
    
    private let apiKey = "AIzaSyCAwf52OWtpbaG26CmHADI-uB7Xtxv3-cA" // 🔒 Replace with your actual API key
    private let radius = 5000  // Search radius in meters
    
    // 🏞 Fetch attractions from Google Places API
    func fetchAttractions(for coordinate: CLLocationCoordinate2D) {
        let type = "tourist_attraction"
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&type=\(type)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        
        isLoading = true // Start loading indicator
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false // Stop loading
            }
            
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let placesResponse = try JSONDecoder().decode(PlacesResponse.self, from: data)
                DispatchQueue.main.async {
                    self.attractions = placesResponse.results
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // 📸 Generate a Google Places image URL
    func getImageURL(for attraction: Attraction) -> String {
        if let photoRef = attraction.photoReference {
            let imageUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoRef)&key=\(apiKey)"
            print("Fetching image from URL: \(imageUrl)")
            return imageUrl
        }
        return "https://source.unsplash.com/200x200/?travel" // Default placeholder
    }
}


