//
//  HomeViewController.swift
//  XAP
//
//  Created by Alex on 6/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import Reachability
import SwiftyAttributes
import SwiftLocation

class HomeViewController: UIViewController {

    @IBOutlet weak var itemCollectionView: CollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    var hidingNavBarManager: HidingNavigationBarManager?
    
    let images: [UIImage] = [#imageLiteral(resourceName: "tmp1"), #imageLiteral(resourceName: "tmp2"), #imageLiteral(resourceName: "tmp3")]
    
    let bottomRefreshControl = UIRefreshControl()
    let pullDownRefreshControl = UIRefreshControl()
    
    var loadedPage = 0
    
    let viewModel = HomeViewModel()
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollection()
        setupLayout()
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: itemCollectionView)
        
        bottomRefreshControl.triggerVerticalOffset = 100
        bottomRefreshControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        itemCollectionView.bottomRefreshControl = bottomRefreshControl
        
        pullDownRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        itemCollectionView.refreshControl = pullDownRefreshControl
        
        setCollectionChangeCallback()
//        refresh()

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("PushNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("UpdatedLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkConditions), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageCount), name: NSNotification.Name("UpdateMessageCount"), object: nil)
        
        itemCollectionView.placeholdersProvider = .basic
        itemCollectionView.placeholderDelegate = self
        
        if self.items.count == 0 {
//            viewModel.changesCallback = nil
            itemCollectionView.showLoadingPlaceholder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAndGetCurrentLocation()
        
        bottomView.frame = CGRect(x: 0, y: view.bounds.height - 100, width: view.bounds.width, height: 100)
        addButton.frame = CGRect(x: bottomView.bounds.width / 2 - 35, y: bottomView.bounds.height / 2 - 50, width: 70, height: 70)
        hidingNavBarManager?.manageBottomBar(bottomView)
        hidingNavBarManager?.viewWillAppear(animated)
        
//        updateMessageCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        checkReachability()
        checkConditions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    private func setupCollection() {
        itemCollectionView.dataSource = self
        itemCollectionView.delegate = self
        itemCollectionView.backgroundColor = .clear
        
//        itemCollectionView.contentInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    }
    
    private func setupLayout() {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 15)
        
        itemCollectionView.collectionViewLayout = layout
        
    }
    
    private func setCollectionChangeCallback() {
        viewModel.changesCallback = { [weak self] signal in
            guard let collectionView = self?.itemCollectionView else { return }
//            signal.apply(to: collectionView, cellUpdater: {[weak self] (cell: ItemCollectionViewCell, indexPath, item) in
//                self?.setupCell(cell: cell, indexPath: indexPath, item: item)
//            })
            debugPrint("setCollectionChangeCallback")
            if let items = self?.viewModel.items{
                self?.items = items
                self?.itemCollectionView.reloadData()
            }
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        openLeftView()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let vc = XAPStoryboard.searchScene.searchVC()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.navigationBar.barTintColor = UIColor(hexString: "0F9CFF")
        present(navVC, animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        if AppContext.shared.userCredentials.userId <= 0 || AppContext.shared.currentUser == nil {
            let vc = XAPStoryboard.landingScene.landingVC()
            self.modalPresentationStyle = .currentContext
            present(vc, animated: true)
            return
        }
        
        let vc = XAPStoryboard.postScene.postItemNameVC()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        present(navVC, animated: true)
    }
    
    func refresh() {
        checkReachability(reachable: { [weak self] _ in
            guard let _self = self else { return }

//            _self.viewModel.changesCallback = nil
            if _self.isLoading == false {
                _self.isLoading = true
                _self.viewModel.refresh(offset: -2).subscribe { _ in
                    _self.isLoading = false
                    self?.pullDownRefreshControl.endRefreshing()
                    
                    self?.checkAndShowEmptyPlaceholder()
                    
                    self?.viewModel.initialFetch()
                    //                if let items = self?.viewModel.items {
                    //                    self?.items = items
                    //                    self?.itemCollectionView.reloadData()
                    //                }
                    
                    
                    }.addDisposableTo(_self.rx_disposeBag)
            }
            
            
        }) { [weak self] _ in
            
            self?.pullDownRefreshControl.endRefreshing()
            
            if let count = self?.self.items.count, count > 0 {
                
            } else {
                self?.itemCollectionView.showNoConnectionPlaceholder()
            }
            
        }
    }
    
    var page:Int = 0
    var isLoading = false
    func loadMore() {
        var p = self.items.count/30 + 1;
        
        p = self.items.count/30
        debugPrint("ppppp",p)
        debugPrint("item count",self.items.count)
        if(self.isLoading == false){
            self.isLoading = true
            viewModel.getItems(offset: p).subscribe { [weak self] evt in
                self?.bottomRefreshControl.endRefreshing()
                self?.viewModel.initialFetch()
                self?.isLoading = false;
                //            if let items = self?.viewModel.items {
                //                self?.items = items
                //                self?.itemCollectionView.reloadData()
                //            }
                }.addDisposableTo(rx_disposeBag)
        }
        
        
        
    }
    
    func checkReachability(reachable: ((Reachability) -> ())? = nil, unreachable: ((Reachability) -> ())? = nil) {
        let reachability = Reachability(hostname: "xap.com.es")

        reachability?.whenReachable = { reach in
            AppContext.shared.isReachable = true
            reachable?(reach)
        }
        
        reachability?.whenUnreachable = { [weak self] reach in
            
            AppContext.shared.isReachable = false
            
            guard let _self = self else { return }
            
            unreachable?(reach)
            
            _self.rx.alert(title: "Network Error".localized, message: "App couldn't connect to our server, because of your network condition.\nPlease check your network and refresh.".localized, cancelTitle: "OK").subscribe().addDisposableTo(_self.rx_disposeBag)
        }
        
        try? reachability?.startNotifier()
    }
    
    
    func checkAndShowEmptyPlaceholder() {
        if self.items.count == 0 {
//            viewModel.changesCallback = nil
            itemCollectionView.showNoResultsPlaceholder()
        } else {
            itemCollectionView.showDefault()
            
            if viewModel.changesCallback == nil {
                setCollectionChangeCallback()
            }
        }
    }
    
    func checkConditions() {
        checkReachability()
        checkAndGetCurrentLocation()
    }
    
    func checkAndGetCurrentLocation() {
        
        guard CLLocationManager.locationServicesEnabled() else {
            
            rx.alert(message: "Turn On Location Services to determine your location".localized, cancelTitle: "Cancel".localized, otherTitles: ["Settings".localized]).subscribe(onNext: { (style, index) in
                guard style == UIAlertActionStyle.default else { return }
//                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
                var settingUrlString : String = ""
                
                if #available(iOS 11, *)  {
                    settingUrlString = UIApplicationOpenSettingsURLString
                } else if #available(iOS 10, *) {
                    settingUrlString = "App-Prefs:root=Privacy&path=LOCATION"
                } else {
                    settingUrlString = "prefs:root=LOCATION_SERVICES"
                }
                
                guard let settingsUrl = URL(string: settingUrlString) else { return }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }).addDisposableTo(rx_disposeBag)
            
            return
        }
        
        if AppContext.shared.currentLocation.latitude == 0,
            AppContext.shared.currentLocation.longitude == 0 {
            
            
            // Get current location
            
            Locator.currentPosition(accuracy: .block, onSuccess: { (location) -> (Void) in
                AppContext.shared.currentLocation = location.coordinate
                NotificationCenter.default.post(name: Notification.Name("UpdatedLocation"), object: nil)
                
                print("Current location: - \(location.coordinate)")
                
                self.refresh()
            }, onFail: { (locationError, location) -> (Void) in
                
                print("Location monitoring failed due to an error \(locationError)")
                
            })
            
            /*
            Locatoion.getLocation(accuracy: .block, frequency: .oneShot, success: { _, location in
                
                AppContext.shared.currentLocation = location.coordinate
                NotificationCenter.default.post(name: Notification.Name("UpdatedLocation"), object: nil)
                
                print("Current location: - \(location.coordinate)")
                
                self.refresh()
                
            }) { request, last, error in
                
                request.cancel()
                print("Location monitoring failed due to an error \(error)")
                
            }
           */
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ItemCollectionViewCell
        let item = self.items[indexPath.item]
        setupCell(cell: cell, indexPath: indexPath, item: item)
        return cell
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        return true
    }
    
    func setupCell(cell: ItemCollectionViewCell, indexPath: IndexPath, item: Item) {
        var url: URL? = nil
        if item.pictureUrls.count > 0 {
            url = try? APIURL(stringLiteral: item.pictureUrls[0] ?? "").asPhotoURL()
        }
        cell.imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "item_placeholder"))
        cell.item = item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = XAPStoryboard.homeScene.itemDetailVC()
        
        if Item.arrangedItems(context: AppContext.shared.mainContext) {
            vc.viewModel = viewModel
        }
        
        vc.item = self.items[indexPath.item]
        show(vc, sender: nil)
    }
    
    func handleNotification() {
        guard let notifData = AppContext.shared.notifData else { return }
        let type = notifData["type"] as! String
        switch type {
        case "message":
            let vc = XAPStoryboard.chatScene.chatListVC()
            show(vc, sender: nil)
        case "price_change":
            let itemId = notifData["item_id"] as! Int
            guard itemId > 0 else { return }
            
            guard let index = self.items.index(where: { $0.id == itemId }) else { return }
            
            let hud = showActivityHUD()
            ItemManager.default.getItem(id: itemId)
                .subscribe(onNext: { [weak self] _ in
                    hud.hide(animated: true)
                    guard let _self = self else { return }
                    let vc = XAPStoryboard.homeScene.itemDetailVC()
                    vc.viewModel = _self.viewModel
                    vc.item = _self.self.items[index]
                    _self.show(vc, sender: nil)
                }).addDisposableTo(rx_disposeBag)
        default:
            break
        }
    }
    
    func updateMessageCount() {
        let unReadCount = Message.totalUnReadCount(context: AppContext.shared.mainContext, userId: AppContext.shared.userCredentials.userId)
        menuBarButton.setBadge(text: "\(unReadCount)")
    }
}

extension HomeViewController: ETCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let image = images[indexPath.item % 3]
        var height = image.height(forWidth: 100)
        
        let budget = "\(self.items[indexPath.item].currency.rawValue) \(self.items[indexPath.item].price)"
        let name = self.items[indexPath.item].title
        
        let budgetHeight = budget.heightForWidth(width: 100 - 16, font: UIFont.systemFont(ofSize: 23))
        let nameHeight = name.heightForWidth(width: 100 - 16, font: UIFont.systemFont(ofSize: 17))
        height += budgetHeight + nameHeight + 25
        
        return CGSize(width: 100, height: height)
    }
}

extension HomeViewController : PlaceholderDelegate {
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        if placeholder.key == .noResultsKey || placeholder.key == .noConnectionKey {
            itemCollectionView.showLoadingPlaceholder()
            refresh()
        }
    }
}
