//
//  LocationManager.swift
//  CoreLocationGeofencing
//
//  Created by Andrey Vasilev on 21.06.2024.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {

    enum Accuracy {
        case bestForNavigation
        case best
        case nearestTenMeters
        case hundredMeters
        case kilometer
        case threeKilometers

        var clAccuracy: CLLocationAccuracy {
            switch self {
            case .bestForNavigation: kCLLocationAccuracyBestForNavigation
            case .best: kCLLocationAccuracyBest
            case .nearestTenMeters: kCLLocationAccuracyNearestTenMeters
            case .hundredMeters: kCLLocationAccuracyHundredMeters
            case .kilometer: kCLLocationAccuracyKilometer
            case .threeKilometers: kCLLocationAccuracyThreeKilometers
            }
        }
    }

    let locationManager: CLLocationManager

    init(accuracy: Accuracy = .best, distanceFilter: Double = 10) {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = accuracy.clAccuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true

        super.init()

        locationManager.delegate = self
    }

    func startUpdatingLocation() {
        handleAuthorizationStatusUpdate(locationManager.authorizationStatus)
    }

    var monitoredRegions: [(String, String)] {
        locationManager.monitoredRegions.map {
            let identifier = $0.identifier
            let type: String
            if $0 is CLCircularRegion {
                type = "Region"
            } else if $0 is CLBeaconRegion {
                type = "Beacon"
            } else {
                type = "Uknown"
            }
            return (identifier, type)
        }
    }

    func startMonitoringRegion(identifier: String, latitude: Double, longitude: Double, radius: Double) {
        let geofenceRegion = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            radius: radius,
            identifier: identifier
        )
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true

        locationManager.startMonitoring(for: geofenceRegion)
    }

    func startMonitoringBeacon(identifier: String, uuid: UUID, major: UInt16?, minor: UInt16?) {
        let geofenceRegion: CLBeaconRegion
        if let major, let minor {
            geofenceRegion = CLBeaconRegion(
                uuid: uuid,
                major: major,
                minor: minor,
                identifier: identifier
            )
        } else if let major {
            geofenceRegion = CLBeaconRegion(
                uuid: uuid,
                major: major,
                identifier: identifier
            )
        } else {
            geofenceRegion = CLBeaconRegion(
                uuid: uuid,
                identifier: identifier
            )
        }
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true

        locationManager.startMonitoring(for: geofenceRegion)
    }

    func stopMonitoringRegion(identifier: String) {
        if let region = locationManager.monitoredRegions.first(where: { $0.identifier == identifier }) {
            locationManager.stopMonitoring(for: region)
        }
    }
}

private extension LocationManager {

    func handleAuthorizationStatusUpdate(_ status: CLAuthorizationStatus) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()

        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            NotificationManager.shared.sendNotification(
                title: "ℹ️ Location authorized always",
                subtitle: "Did start updating location"
            )

        case .restricted, .denied:
            NotificationManager.shared.sendNotification(
                title: "⚠️ Location invalid authorization status",
                subtitle: "\(locationManager.authorizationStatus)"
            )
        @unknown default:
            NotificationManager.shared.sendNotification(
                title: "⚠️ Location invalid authorization status",
                subtitle: "\(locationManager.authorizationStatus)"
            )
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatusUpdate(locationManager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("ℹ️ didUpdateLocations: ", locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationManager.shared.sendNotification(
            title: "⚠️ Location didFailWithError",
            subtitle: "\(error.localizedDescription)"
        )
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NotificationManager.shared.sendNotification(
            title: "🚩 didEnterRegion",
            subtitle: "\(region.identifier)"
        )
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NotificationManager.shared.sendNotification(
            title: "🏁 didExitRegion",
            subtitle: "\(region.identifier)"
        )
    }
}
