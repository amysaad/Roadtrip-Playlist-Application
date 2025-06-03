import CoreLocation

func getCoordinates(for address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { placemarks, error in
        guard let location = placemarks?.first?.location else {
            completion(nil)
            return
        }
        completion(location.coordinate)
    }
}
