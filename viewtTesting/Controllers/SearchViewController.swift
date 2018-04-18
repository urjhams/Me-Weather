//
//  SearchViewController.swift
//  viewtTesting
//
//  Created by urjhams on 3/9/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var outsideView: UIView!
    @IBOutlet weak var upsideView: UIView!
    var rootViewController: ViewController?
    var resultArray = [CityLocation]()
    var citiesArray = [CityLocation]()
    var loaded: Bool? {
        didSet {
            if loaded! {
                hideLoading()
            } else {
                showLoading()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        upsideView.isUserInteractionEnabled = true
        upsideView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickOutSide)))
        
        prepareSearchBar(of: searchBar)
        
        loaded = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCities { [weak self] in
            self?.loaded = true
        }
    }
    @IBAction func touchBack(_ sender: UIButton) {
        self.searchBar.endEditing(true)
        self.dismiss(animated: true) {
        }
    }
    private func prepareSearchBar(of bar:UISearchBar) {
        bar.isTranslucent = true
        bar.backgroundImage = UIImage()
        bar.tintColor = UIColor.clear
        bar.alpha = 0.7
        bar.placeholder = "City name"
    }
    private func showLoading() {
        loadingSpinner.startAnimating()
        loadingLabel.isHidden = false
        loadingSpinner.isHidden = false
        searchBar.isUserInteractionEnabled = false
    }
    private func hideLoading() {
        loadingSpinner.stopAnimating()
        loadingLabel.isHidden = true
        loadingSpinner.isHidden = true
        searchBar.isUserInteractionEnabled = true
    }
    private func getCities(completion: @escaping () -> ()) {
        if let loadedCities = UserDefaults.standard.array(forKey: "Cities") as? [NSDictionary] {
            for dict in loadedCities {
                if let city = CityLocation(withData: dict) {
                    self.citiesArray.append(city)
                }
            }
            self.loaded = true
        } else {
            let url = URL(string: Constants.CityLocateApi.baseUrl)
            DispatchQueue.global(qos: .userInitiated).async {
                let group = DispatchGroup()
                group.enter()
                Alamofire.request(url!).responseJSON { [weak self](response) in
                    if let json = response.result.value as? [NSDictionary] {
                        for dictionary in json {
                            if let city = CityLocation(withData: dictionary) {
                                self?.citiesArray.append(city)
                            }
                        }
                        group.leave()
                        UserDefaults.standard.set(json, forKey: "Cities")
                        print(UserDefaults.standard.array(forKey: "Cities") ?? "nothin")
                    }
                }
                group.wait()
                DispatchQueue.main.sync {
                    completion()
                }
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultSearchTableViewCell
        let object = resultArray[indexPath.row]
        cell.contentLabel.text = object.name + ", " + object.country
        cell.lat = Double(object.latitude)
        cell.long = Double(object.longtitude)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = resultArray[indexPath.row]
        let name = selected.name
        let country = selected.country
        let lat = Double(selected.latitude)
        let long = Double(selected.longtitude)
        tableView.deselectRow(at: indexPath, animated: true)
        if let root = self.rootViewController {
            searchBar.endEditing(true)
            dismiss(animated: true, completion: {
                root.setSpecificLocation(name: name, country: country)
                root.getSpecificCurrentWeatherForecast(withLatitude: lat!, andLongtitude: long!)
            })
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchBar.text != "" {
            handleKeyword(searchBar.text!)
            resultTableView.reloadData()
        } else {
            resultArray = [CityLocation]()
            resultTableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.endEditing(true)
        return true
    }
}

extension SearchViewController {
    private func handleKeyword(_ keyword: String) {
        resultArray = [CityLocation]()
        for city in citiesArray {
            if city.name.contains(keyword) {
                resultArray.append(city)
            }
        }
    }
    @objc private func clickOutSide() {
        self.searchBar.endEditing(true)
    }
}
