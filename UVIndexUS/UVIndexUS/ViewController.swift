//
//  ViewController.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var uvIndexDescriptionLabel: UILabel!
    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var dateFormatter = NSDateFormatter()
    var locationManager : CLLocationManager!
    var indicator : SDevIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        getTheStuff()
    }
    
    func getTheStuff() {
        if indicator != nil {
            indicator.dismissIndicator()
        }
        indicator = SDevIndicator.generate(self.view)!
        
        infoLabel.text = ""
        uvIndexDescriptionLabel.text = ""
        uvIndexLabel.text = ""
        errorLabel.text = ""
        self.view.backgroundColor = UIColor.whiteColor()
        
        getLocation()
    }
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        locationManager.stopUpdatingLocation()
        var locationArray = locations as NSArray
        var currentLocation = locationArray.lastObject as? CLLocation
        getUVIndex(currentLocation!)
    }
    
    func getUVIndex(currentLocation : CLLocation) {
        ForecastRetriever(delegate: self).getUVIndex(currentLocation, delegate: self)
    }
    
    func didNotFindValidCountry(country : NSString) {
        indicator.dismissIndicator()
        
        errorLabel.text = "Oh no :( This app cannot find UV Index outside the US, and you are in " + country + "."
    }
    
    func didNotReceivedUvIndexOrCity() {
        indicator.dismissIndicator()
        
        errorLabel.text = "Oh no :( Could for some reason not find any UV Index for your location. Make sure you have internet access, that this app has access to your location and then touch anywhere on the screen to try again."
    }
    
    func didReceiveUVIndexForLocationAndTime(uvIndex: String, city: String, state: String, timeStamp: NSDate) {
        indicator.dismissIndicator()
        infoLabel.text = buildInfoText(city, state: state, timeStamp: timeStamp)
        uvIndexDescriptionLabel.text = buildDescriptionForUVIndex(uvIndex)
        infoLabel.textColor = UIColor.blackColor()
        uvIndexDescriptionLabel.textColor = UIColor.blackColor()
        uvIndexLabel.textColor = UIColor.blackColor()
        uvIndexLabel.text = uvIndex
        self.view.backgroundColor = getBackgroundColorForUVIndex(uvIndex)
    }
    
    func buildInfoText(city: String, state: String, timeStamp: NSDate) -> NSString {
        return "UV Index in " + city + " (" + state + ") at " + dateFormatter.stringFromDate(timeStamp)
    }
    
    func buildDescriptionForUVIndex(uvIndex: String) -> NSString {
        return "is " + getDescriptionForUVIndex(uvIndex)
    }
    
    func getDescriptionForUVIndex(uvIndex: String) -> NSString {
        switch uvIndex {
        case "":
            return "UNKNOWN :("
        case "0", "1", "2":
            return "LOW"
        case "3", "4", "5":
            return "MODERATE"
        case "6", "7":
            return "HIGH"
        case "8", "9", "10":
            return "VERY HIGH"
        default:
            return "EXTREME"
        }
    }
    
    func getBackgroundColorForUVIndex(uvIndex: String) -> UIColor {
        switch uvIndex {
        case "":
            return UIColor.lightGrayColor()
        case "0", "1", "2":
            return UIColor(red: 0.459, green: 0.757, blue: 0.282, alpha: 1.0)
        case "3", "4", "5":
            return UIColor(red: 0.918, green: 0.925, blue: 0.4, alpha: 1.0)
        case "6", "7":
            return UIColor(red: 0.886, green: 0.455, blue: 0.184, alpha: 1.0)
        case "8", "9", "10":
            return UIColor(red: 0.886, green: 0.204, blue: 0.184, alpha: 1.0)
        default:
            return UIColor(red: 0.6, green: 0.125, blue: 0.561, alpha: 1.0)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        getTheStuff()
    }

}

