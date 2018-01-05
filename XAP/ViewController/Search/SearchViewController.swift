//
//  SearchViewController.swift
//  XAP
//
//  Created by Alex on 14/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import MapKit
import RangeSeekSlider

enum Distance: Int {
    case mile1 = 0
    case mile5 = 1
    case mile10 = 2
    case mileOver10 = 3
    
    var text: String {
        switch self {
        case .mile1:
            return "Close (1 mile)".localized
        case .mile5:
            return "My area (5 miles)".localized
        case .mile10:
            return "My city (10 miles)".localized
        case .mileOver10:
            return "Far (10+ miles)".localized
        }
    }
    
    var mapDelta: Float {
        switch self {
        case .mile1:
            return 0.015
        case .mile5:
            return 0.075
        case .mile10:
            return 0.15
        case .mileOver10:
            return 0.5
        }
    }
    
    var distance: Int {
        switch self {
        case .mile1:
            return 2
        case .mile5:
            return 8
        case .mile10:
            return 16
        case .mileOver10:
            return 16
        }
    }
}

class SearchViewController: UIViewController {
    
    enum PublishDateOption {
        case hour24
        case day7
        case day30
        
        var date: Date {
            switch self {
            case .hour24:
                return Date().dateBefore(days: 1)
            case .day7:
                return Date().dateBefore(days: 7)
            case .day30:
                return Date().dateBefore(days: 30)
            }
        }
    }

    @IBOutlet weak var searchTitleTextView: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var priceRangeSlider: RangeSeekSlider!
    
    @IBOutlet weak var date24HoursView: UIView!
    @IBOutlet weak var date30DaysView: UIView!
    @IBOutlet weak var date7DaysView: UIView!
    
    @IBOutlet weak var deliverView: UIView!
    @IBOutlet weak var acceptTradeView: UIView!
    
    @IBOutlet weak var sortByIconImageView: UIImageView!
    @IBOutlet weak var sortByTextLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var viewModel = SearchViewModel()
    
    var publishDateOption: PublishDateOption = .hour24 {
        didSet {
            date24HoursView.alpha = 0.5
            date7DaysView.alpha = 0.5
            date30DaysView.alpha = 0.5
            
            switch publishDateOption {
            case .hour24:
                date24HoursView.alpha = 1
            case .day7:
                date7DaysView.alpha = 1
            case .day30:
                date30DaysView.alpha = 1
            }
            
            viewModel.publishedDate = publishDateOption.date
        }
    }
    
    var isDelivers: Bool = true {
        didSet {
            if isDelivers {
                deliverView.alpha = 1.0
            } else {
                deliverView.alpha = 0.5
            }
            viewModel.isShippable = isDelivers
        }
    }
    
    var isAcceptTrade: Bool = true {
        didSet {
            if isAcceptTrade {
                acceptTradeView.alpha = 1.0
            } else {
                acceptTradeView.alpha = 0.5
            }
            viewModel.isAcceptable = isAcceptTrade
        }
    }
    
    var sortBy: SortBy = .distance {
        didSet {
            sortByIconImageView.image = sortBy.icon
            sortByTextLabel.text = sortBy.string
            viewModel.sortby = sortBy
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        priceRangeSlider.delegate = self

        isDelivers = false
        isAcceptTrade = false
        
        date24HoursView.alpha = 1.0
        date7DaysView.alpha = 0.5
        date30DaysView.alpha = 0.5
        
        self.initializeDB()
    }
    
    var isLoading = false;
    func initializeDB(){
        if(AppContext.itemRefreshed_search){
            self.viewModel.initialFetch()
        }else{
            let hud = showActivityHUD()
            if(self.isLoading == false){
                ItemManager.default.refreshItems(offset: -2)
                    .map {_ in
                        self.viewModel.initialFetch()
                    }.subscribe { _ in
                        self.isLoading = false
                        hud.hide(animated: true)
                        AppContext.itemRefreshed_search = true
                    }.addDisposableTo(self.rx_disposeBag)
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = AppContext.shared.currentLocation
        mapView.addAnnotation(annotation)
        
        priceLabel.text = "$\(Int(priceRangeSlider.selectedMinValue)) - $\(Int(priceRangeSlider.selectedMaxValue))"
        
        distanceLabel.text = viewModel.distance.text
        setMapViewRegion(distance: viewModel.distance)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        viewModel.searchTitle = searchTitleTextView.text ?? ""
        viewModel.initFilter()
        
        let vc = XAPStoryboard.searchScene.searchResultVC()
        vc.viewModel = viewModel
        show(vc, sender: nil)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func distanceSliderValueChanged(_ sender: Any) {
        let distance = Distance(rawValue: Int(roundf(distanceSlider.value))) ?? .mile1
        distanceSlider.value = Float(distance.rawValue)
        distanceLabel.text = distance.text
        
        viewModel.distance = distance
        setMapViewRegion(distance: distance)
    }
    
    @IBAction func date24HoursTapped(_ sender: Any) {
        publishDateOption = .hour24
    }
    
    @IBAction func date7DaysTapped(_ sender: Any) {
        publishDateOption = .day7
    }
    
    @IBAction func date30DaysTapped(_ sender: Any) {
        publishDateOption = .day30
    }
    
    @IBAction func deliverTapped(_ sender: Any) {
        isDelivers = !isDelivers
    }
    
    @IBAction func acceptTradeTapped(_ sender: Any) {
        isAcceptTrade = !isAcceptTrade
    }
    
    @IBAction func sortByTapped(_ sender: Any) {
        let vc = XAPStoryboard.searchScene.selectSortByVC()
        vc.selectedSortByHandler = { [weak self] sortBy in
            self?.sortBy = sortBy
        }
        self.modalPresentationStyle = .currentContext
        present(vc, animated: true)
    }
    
    func setMapViewRegion(distance: Distance) {
        let region = MKCoordinateRegion(center: AppContext.shared.currentLocation,
                                        span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(distance.mapDelta), longitudeDelta: CLLocationDegrees(distance.mapDelta)))
        mapView.setRegion(region, animated: true)
    }
}

extension SearchViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        let priceText = "$\(Int(minValue)) - $\(Int(maxValue))"
        priceLabel.text = priceText
        
        viewModel.minPrice = Int(minValue)
        viewModel.maxPrice = Int(maxValue)
    }
}
