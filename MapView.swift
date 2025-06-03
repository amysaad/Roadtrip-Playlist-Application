import MapKit
import SwiftUI

struct Waypoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

struct MapView: UIViewRepresentable {
    @Binding var startCoordinate: CLLocationCoordinate2D?
    @Binding var endCoordinate: CLLocationCoordinate2D?
    @Binding var selectedPinTitle: String?
    var waypoints: [Waypoint] = []

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "CustomPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            switch annotation.title ?? "" {
            case "Start":
                annotationView?.markerTintColor = .systemGreen
                annotationView?.glyphText = "Start"
            case "Destination":
                annotationView?.markerTintColor = .systemRed
                annotationView?.glyphText = "End"
            default:
                annotationView?.markerTintColor = .systemPurple
                annotationView?.glyphText = "•"
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let title = view.annotation?.title ?? "" {
                parent.selectedPinTitle = title
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        guard let start = startCoordinate, let end = endCoordinate else { return }

        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = start
        startAnnotation.title = "Start"
        mapView.addAnnotation(startAnnotation)

        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = end
        endAnnotation.title = "Destination"
        mapView.addAnnotation(endAnnotation)

        for waypoint in waypoints {
            let annotation = MKPointAnnotation()
            annotation.coordinate = waypoint.coordinate
            annotation.title = waypoint.title
            mapView.addAnnotation(annotation)
        }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, error in
            if let route = response?.routes.first {
                mapView.addOverlay(route.polyline)
                let region = MKCoordinateRegion(route.polyline.boundingMapRect)
                mapView.setRegion(region, animated: true)
            }
        }
    }
}
