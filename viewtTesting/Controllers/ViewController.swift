//
//  ViewController.swift
//  viewtTesting
//
//  Created by urjhams on 3/7/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import JTMaterialTransition

class ViewController: UIViewController {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var farenheitButton: UIButton!
    @IBOutlet weak var CelciusButton: UIButton!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var mainIconImageView: UIImageView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    let childIconNameArray = ["humidity","windSpeed","cloud","pressure","visibility"]
    let childTitleArray = ["Humidity","Wind speed","Cloud","Pressure","Visibility"]
    let statusDict = ["clear-day":"Clear day",
                      "clear-night":"Clear night",
                      "cloudy":"Most cloudy",
                      "fog":"Fogging",
                      "hail":"May has hailing",
                      "partly-cloudy-day":"Partly cloudy day",
                      "partly-cloudy-night":"Partly cloudy night",
                      "rain":"Rainning",
                      "sleet":"Sleeting",
                      "snow":"Has snowing",
                      "thunderstorm":"Thunderstorm",
                      "tornado":"Tornado",
                      "wind":"Windy"]
    var childValueArray = [String]()
    var hourlyArray = [HourlyModel]()
    let locationManager = CLLocationManager()
    var currentLocationName = "" {
        didSet {
            locationLabel.text = currentLocationName
        }
    }
    var currentContry = "" {
        didSet {
            countryLabel.text = currentContry
        }
    }
    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            if let lat = currentLocation?.latitude, let long = currentLocation?.longitude {
                self.getCurrentWeatherForecast(withLatitue: lat, andLongtitue: long)
            }
            if let location = locationManager.location {
                self.setLocationName(fromLocation: location)
            }
        }
    }
    var currentTempInF: Int? {
        didSet {
            if let temp = currentTempInF {
                self.tempLabel.text = String(Int(currentTempMode == .F ? temp : Int(convertToC(fromF: Double(temp))))) + "º"
            } else {
                self.tempLabel.text = "_ _º"
            }
        }
    }
    var isTracking:Bool? {  // help in handle when user click on curently location button or when load current location first time
        didSet {
            if isTracking! {
                locationManager.startUpdatingLocation()
            } else {
                locationManager.stopUpdatingLocation()
            }
        }
    }
    var transition: JTMaterialTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //self.locationManager.startUpdatingLocation()
            isTracking = true
        }
        hourlyCollectionView.delegate = self
        hourlyCollectionView.dataSource = self
        infoTableView.delegate = self
        infoTableView.dataSource = self
        transition = JTMaterialTransition(animatedView: self.searchLocationButton)
        prepareButton()
    }
    
    private func prepareButton() {
        CelciusButton.addTarget(self, action: #selector(clickCelcius(_:)), for: .touchUpInside)
        farenheitButton.addTarget(self, action: #selector(clickFarenheit(_:)), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(clickLocation(_:)), for: .touchUpInside)
        searchLocationButton.addTarget(self, action: #selector(clickSearch(_:)), for: .touchUpInside)
        if currentTempMode == .F {
            CelciusButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            farenheitButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            farenheitButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            CelciusButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
}

extension ViewController {
    @objc private func clickSearch(_ sender: UIButton) {
        if let destination = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "searchVC") as? SearchViewController {
            destination.rootViewController = self
            destination.modalPresentationStyle = .custom
            destination.transitioningDelegate = self.transition
            self.present(destination, animated: true, completion: {
                self.isTracking = false
            })
        }
    }
    @objc private func clickLocation(_ sender: UIButton) {
        isTracking = true
        let location = self.currentLocation!
        self.currentLocation = location
    }
    @objc private func clickCelcius(_ sender: UIButton) {
        if currentTempMode == .F {
            currentTempMode = .C
            hourlyCollectionView.reloadData()
            farenheitButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            CelciusButton.setTitleColor(UIColor.white, for: .normal)
            if let temp = currentTempInF {
                currentTempInF = temp
            }
        }
    }
    @objc private func clickFarenheit(_ sender: UIButton) {
        if currentTempMode == .C {
            currentTempMode = .F
            hourlyCollectionView.reloadData()
            CelciusButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            farenheitButton.setTitleColor(UIColor.white, for: .normal)
            if let temp = currentTempInF {
                currentTempInF = temp
            }
        }
    }
}

extension ViewController {
    // specific location
    func setSpecificLocation(name: String, country: String) {
        self.currentLocationName = name
        self.currentContry = country
    }
    func getSpecificCurrentWeatherForecast(withLatitude lat: Double, andLongtitude long: Double) {
        let urlString = Constants.DarkSkyApi.baseUrl + Constants.DarkSkyApi.secrectKey + "/\(lat),\(long)"
        let url = URL(string: urlString)
        Alamofire.request(url!).responseJSON { [weak self] (response) in
            if let status = response.response?.statusCode {
                switch status {
                case 200:
                    if let json = response.result.value as? NSDictionary {
                        self?.handleWeatherJson(from: json)
                    }
                default:
                    break
                }
            }
        }
    }
    
    // current location
    private func getCurrentWeatherForecast(withLatitue lat: CLLocationDegrees, andLongtitue long: CLLocationDegrees) {
        let urlString = Constants.DarkSkyApi.baseUrl + Constants.DarkSkyApi.secrectKey + "/\(lat),\(long)"
        let url = URL(string: urlString)
        Alamofire.request(url!).responseJSON { [weak self] (response) in
            if let status = response.response?.statusCode {
                switch status {
                case 200:
                    if let json = response.result.value as? NSDictionary {
                        self?.handleWeatherJson(from: json)
                    }
                default:
                    break
                }
            }
        }
    }
    private func setLocationName(fromLocation location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { [weak self](placeMarks, error) in
            self?.currentLocationName = placeMarks?.first?.name ?? ""
            self?.currentContry = placeMarks?.first?.country ?? ""
        })
    }
    
    // handle result
    private func handleWeatherJson(from json: NSDictionary) {
        if let currentData = json[Constants.DarkSkyApi.currentlyKey] as? NSDictionary {
            if let model = CurrentWeatherModel(withData: currentData) {
                self.childValueArray = [String]()
                self.childValueArray.append(String(Int(model.humidity * 100)) + " %")
                self.childValueArray.append(String(model.windSpd) + " mile/h")
                self.childValueArray.append(String(Int(model.cloud * 100)) + " %")
                self.childValueArray.append(String(model.pressure))
                self.childValueArray.append(String(Int(model.visibility)) + " km")
                infoTableView.reloadData()
                self.currentTempInF = Int(model.temp)
                self.backgroundView.image = UIImage(named: model.icon + "-bg")
                self.mainIconImageView.image = UIImage(named: model.icon + "-icon")
                self.statusLabel.text = statusDict[model.icon] ?? ""
            }
        }
        if let hourly = json[Constants.DarkSkyApi.hourlyKey] as? NSDictionary {
            if let hours = hourly["data"] as? [NSDictionary] {
                self.hourlyArray = [HourlyModel]()
                for hour in hours {
                    let current = Int64(NSDate().timeIntervalSince1970)
                    if let hourModel = HourlyModel(withData: hour) {
                        if hourModel.time > current, hourModel.time < Int64(Date().tomorrow.timeIntervalSince1970) {
                            self.hourlyArray.append(hourModel)
                        }
                    }
                }
                hourlyCollectionView.reloadData()
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = manager.location?.coordinate
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childValueArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoTableViewCell
        cell.titleLabel.text = childTitleArray[indexPath.row]
        cell.contentLabel.text = childValueArray[indexPath.row]
        cell.iconImage.image = UIImage(named: childIconNameArray[indexPath.row])
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hourlyCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HourlyCollectionViewCell
        cell.hourlyUnit = hourlyArray[indexPath.item]
        return cell
    }

}




