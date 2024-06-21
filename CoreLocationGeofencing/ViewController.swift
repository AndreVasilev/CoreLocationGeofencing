//
//  ViewController.swift
//  CoreLocationGeofencing
//
//  Created by Andrey Vasilev on 21.06.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextField: UITextField!

    @IBOutlet weak var regionIdentifierTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!

    @IBOutlet weak var beaconIdentifierTextField: UITextField!
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!

    @IBOutlet weak var removingIdentifierTextField: UITextField!

    @IBOutlet weak var monitoredRegionsLabel: UILabel!

    private var manualNotificationsCounter: Int = 0
    private lazy var locationManager = LocationManager()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationManager.shared.requestAuthorization()
        locationManager.startUpdatingLocation()
        reloadMonitoringData()
    }

    @IBAction func sendNotification(_ sender: UIButton) {
        manualNotificationsCounter += 1
        let title = titleTextField.text?.isEmpty == false ? titleTextField.text! : "Title #\(manualNotificationsCounter)"
        let subtitle = subtitleTextField.text?.isEmpty == false ? subtitleTextField.text! : "Fired at: \(Date.now)"

        NotificationManager.shared.sendNotification(title: title, subtitle: subtitle)
    }

    @IBAction func startMonitoringRegion(_ sender: UIButton) {
        guard let identifier = regionIdentifierTextField.text, !identifier.isEmpty,
              let latitudeString = latitudeTextField.text, let latitude = NumberFormatter().number(from: latitudeString)?.doubleValue,
              let longitudeString = longitudeTextField.text, let longitude = NumberFormatter().number(from: longitudeString)?.doubleValue,
              let radiusString = radiusTextField.text, let radius = NumberFormatter().number(from: radiusString)?.doubleValue
        else {
            NotificationManager.shared.sendNotification(title: "⚠️ Monitoring region failed", subtitle: "Invalid parameters")
            return
        }

        locationManager.startMonitoringRegion(identifier: identifier, latitude: latitude, longitude: longitude, radius: radius)
        reloadMonitoringData()
    }

    @IBAction func startMonitoringBeacon(_ sender: UIButton) {
        guard let identifier = regionIdentifierTextField.text, !identifier.isEmpty,
              let uuidString = uuidTextField.text, let uuid = UUID(uuidString: uuidString)
        else {
            NotificationManager.shared.sendNotification(title: "⚠️ Monitoring beacon failed", subtitle: "Invalid parameters")
            return
        }
        var major: UInt16?
        if let string = majorTextField.text {
            major = UInt16(string)
        }
        var minor: UInt16?
        if let string = minorTextField.text {
            minor = UInt16(string)
        }

        locationManager.startMonitoringBeacon(identifier: identifier, uuid: uuid, major: major, minor: minor)
        reloadMonitoringData()
    }

    @IBAction func stopMonitoring(_ sender: UIButton) {
        guard let identifier = removingIdentifierTextField.text, !identifier.isEmpty
        else {
            NotificationManager.shared.sendNotification(title: "⚠️ Monitoring stop failed", subtitle: "Missing identifier")
            return
        }

        locationManager.stopMonitoringRegion(identifier: identifier)
        reloadMonitoringData()
    }
}

private extension ViewController {

    func reloadMonitoringData() {
        let text = locationManager.monitoredRegions
            .map { "\($0.0) (\($0.1))" }
            .joined(separator: "\n")
        monitoredRegionsLabel.text = text.isEmpty ? "none" : text
    }
}
