//
//  ForecastRepository.swift
//  UVIndexNordic
//
//  Created by Per Jansson on 2014-12-06.
//  Copyright (c) 2014 Per Jansson. All rights reserved.
//

import Foundation
import CoreLocation

typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>

class ForecastRetriever : NSObject, NSXMLParserDelegate {
    
    let FORECAST_PROVIDER_URL = "http://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVDAILY/CITY/%@/STATE/%@/JSON"
    let stateDictionary : Dictionary<String, String>
    
    var delegate : ViewController
    
    var uvIndex : String
    var city : String
    var state : String
    
    let responseData = NSMutableData()
    
    init(delegate:ViewController) {
        self.delegate = delegate
        self.uvIndex = ""
        self.city = ""
        self.state = ""
        
        stateDictionary = ["alabama":"AL",
        "alaska":"AK",
        "arizona":"AZ",
        "arkansas":"AR",
        "california":"CA",
        "colorado":"CO",
        "connecticut":"CT",
        "delaware":"DE",
        "district of columbia":"DC",
        "florida":"FL",
        "georgia":"GA",
        "hawaii":"HI",
        "idaho":"ID",
        "illinois":"IL",
        "indiana":"IN",
        "iowa":"IA",
        "kansas":"KS",
        "kentucky":"KY",
        "louisiana":"LA",
        "maine":"ME",
        "maryland":"MD",
        "massachusetts":"MA",
        "michigan":"MI",
        "minnesota":"MN",
        "mississippi":"MS",
        "missouri":"MO",
        "montana":"MT",
        "nebraska":"NE",
        "nevada":"NV",
        "new hampshire":"NH",
        "new jersey":"NJ",
        "new mexico":"NM",
        "new york":"NY",
        "north carolina":"NC",
        "north dakota":"ND",
        "ohio":"OH",
        "oklahoma":"OK",
        "oregon":"OR",
        "pennsylvania":"PA",
        "rhode island":"RI",
        "south carolina":"SC",
        "south dakota":"SD",
        "tennessee":"TN",
        "texas":"TX",
        "utah":"UT",
        "vermont":"VT",
        "virginia":"VA",
        "washington":"WA",
        "west virginia":"WV",
        "wisconsin":"WI",
        "wyoming":"WY"]
        
        super.init()
    }
    
    func getUVIndex(currentLocation : CLLocation, delegate : ViewController) {
        CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler:
            {(placemarks, error) in
                if placemarks.count > 0 {
                    let placeMark = placemarks[0] as CLPlacemark
                    if self.isValidCountry(placeMark.ISOcountryCode) {
                        var c = placeMark.locality
                        var s = placeMark.administrativeArea
                        if c != nil && s != nil {
                            self.getUVIndexForCity(c, forState: s)
                            return
                        }
                    } else {
                        self.delegate.didNotFindValidCountry(placeMark.country)
                        return
                    }
                }
                self.delegate.didNotReceivedUvIndexOrCity()
        })
    }
    
    func getUVIndexForCity(city: String, forState state: String) {
        var url = NSURL(string : String(format: self.FORECAST_PROVIDER_URL, city, state).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSURLRequest(URL: url!)
        println(url)
        let conn = NSURLConnection(request: request, delegate:self)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.responseData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var json : AnyObject! = NSJSONSerialization.JSONObjectWithData(self.responseData, options: NSJSONReadingOptions.MutableLeaves, error: nil)
        var forecasts = self.handleGetForecasts(json)
        if !forecasts.isEmpty {
            var forecast = forecasts[0]
            self.city = forecast.city!
            self.state = forecast.state!
            self.uvIndex = forecast.uvIndex!
            self.returnResultToDelegate()
        } else {
            self.delegate.didNotReceivedUvIndexOrCity()
        }
    }
    
    func handleGetForecasts(json: AnyObject) -> [Forecast] {
        var forecasts = Array<Forecast>()
        if let forecastObjects = json as? JSONArray {
            for forecastObject: AnyObject in forecastObjects {
                if let forecastAsJson = forecastObject as? JSONDictionary {
                    if let forecast = Forecast.createFromJson(forecastAsJson) {
                        forecasts.append(forecast)
                    }
                }
            }
        }
        return forecasts
    }
    
    func isValidCountry(ISOcountryCode : NSString) -> Bool {
        return ISOcountryCode == "US"
    }
    
    func returnResultToDelegate() {
        if hasUVIndex() && hasCityAndState() {
            self.delegate.didReceiveUVIndexForLocationAndTime(self.uvIndex, city: self.city, state: self.state, timeStamp: NSDate())
        } else {
            self.delegate.didNotReceivedUvIndexOrCity()
        }
    }
    
    func hasUVIndex() -> Bool {
        return self.uvIndex != ""
    }
    
    func hasCityAndState() -> Bool {
        return self.city != "" && self.state != ""
    }
    
}
