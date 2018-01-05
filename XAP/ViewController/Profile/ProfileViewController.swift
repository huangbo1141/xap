//
//  ProfileViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import MapKit
import IBAnimatable
import Kingfisher
import RxSwift

class ProfileViewController: UIViewController {
    
    enum ContentType {
        case selling
        case sold
        case reviews
        case faves
    }

    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var partiallyVerifiedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var partiallyVerifiedView: UIView!
    @IBOutlet weak var sellingItemsCollectionView: UICollectionView!
    @IBOutlet weak var soldItemsCollectionView: UICollectionView!
    @IBOutlet weak var favsItemsCollectionView: UICollectionView!
    
//    @IBOutlet weak var sellingItemCollectionViewLayout: PinterestLayout!
//    @IBOutlet weak var soldItemCollectionViewLayout: PinterestLayout!
//    @IBOutlet weak var favItemCollectionViewLayout: PinterestLayout!
    
    @IBOutlet weak var favItemCountLabel: UILabel!
    @IBOutlet weak var soldItemCountLabel: UILabel!
    @IBOutlet weak var sellingItemCountLabel: UILabel!
    
    @IBOutlet weak var sellingButtonView: UIView!
    @IBOutlet weak var soldButtonView: UIView!
    @IBOutlet weak var reviewButtonView: UIView!
    @IBOutlet weak var faveButtonView: UIView!
    
    @IBOutlet weak var emailVerifiedButton: UIButton!
    @IBOutlet weak var phoneVerifiedButton: UIButton!
    @IBOutlet weak var facebookVerifiedButton: UIButton!
    @IBOutlet weak var googleVerifiedButton: UIButton!
    @IBOutlet weak var birthdayVerifiedButton: UIButton!
    @IBOutlet weak var genderVerifiedButton: UIButton!
    @IBOutlet weak var positionVerifiedButton: UIButton!
    @IBOutlet weak var profileVerifiedButton: UIButton!
    
    @IBOutlet weak var favTabWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var favTabZeroWidthConstraint: NSLayoutConstraint!
    
    let images: [UIImage] = [#imageLiteral(resourceName: "tmp1"), #imageLiteral(resourceName: "tmp2"), #imageLiteral(resourceName: "tmp3")]
    let budget: [String] = ["USD2,300", "EUR423", "CNY6,000"]
    let itemName: [String] = ["This is beautiful sea", "This is city", "Boy catched sun!"]
    
    var viewModel: ProfileViewModel!
    
    var selectedType: ContentType = .selling {
        didSet {
            resetSelectedButton()
            switch selectedType {
            case .selling:
                sellingButtonView.alpha = 1.0
                sellingItemsCollectionView.isHidden = false
            case .sold:
                soldButtonView.alpha = 1.0
                soldItemsCollectionView.isHidden = false
            case .reviews:
                reviewButtonView.alpha = 1.0
            case .faves:
                faveButtonView.alpha = 1.0
                favsItemsCollectionView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollection()
        setupLayout()
        
        resetSelectedButton()
        selectedType = .selling
        sellingButtonView.alpha = 1.0
        
        soldItemsCollectionView.isHidden = true
        favsItemsCollectionView.isHidden = true
        
        viewModel.sellingItemsChangesCallback = { [weak self] signal in
            guard let collectionView = self?.sellingItemsCollectionView else { return }
            signal.apply(to: collectionView, cellUpdater: { (cell: ItemCollectionViewCell, indexPath, item) in
                self?.setupCell(cell: cell, indexPath: indexPath, item: item)
            })
            
            self?.sellingItemCountLabel.text = "\(self?.viewModel.sellingItems.count ?? 0)"
            self?.soldItemCountLabel.text = "\(self?.viewModel.soldItems.count ?? 0)"
//            self?.favItemCountLabel.text = "\(AppContext.shared.currentUser?.favItems.count ?? 0)"
            self?.favItemCountLabel.text = "\(self?.viewModel.user.favItems.count ?? 0)"
        }
        
        sellingItemCountLabel.text = "\(viewModel.sellingItems.count)"
        soldItemCountLabel.text = "\(viewModel.soldItems.count)"
//        favItemCountLabel.text = "\(AppContext.shared.currentUser?.favItems.count ?? 0)"
        favItemCountLabel.text = "\(viewModel.user.favItems.count ?? 0)"
        
        if viewModel.user.id != AppContext.shared.userCredentials.userId {
            navigationItem.rightBarButtonItems = nil
            favTabWidthConstraint.isActive = false
            favTabZeroWidthConstraint.isActive = true
        } else {
            favTabWidthConstraint.isActive = true
            favTabZeroWidthConstraint.isActive = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        userNameLabel.text = viewModel.userName.value
        
        avatarImageView.kf.setImage(with: viewModel.profileImageUrl, placeholder: #imageLiteral(resourceName: "ic_face")) { image, _, _, _ in
            AppContext.shared.currentUser?.avatarImage = image
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = AppContext.shared.currentLocation
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: AppContext.shared.currentLocation,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        
        guard let _currentUser = AppContext.shared.currentUser else { return }
        facebookVerifiedButton.alpha = _currentUser.facebook != "" ? 1.0 : 0.4
        googleVerifiedButton.alpha = _currentUser.google != "" ? 1.0 : 0.4
        emailVerifiedButton.alpha = _currentUser.verifyEmail == "verified" ? 1.0 : 0.4
        birthdayVerifiedButton.alpha = (_currentUser.birthday_ ?? "") != "" ? 1.0 : 0.4
        genderVerifiedButton.alpha = 1.0
        positionVerifiedButton.alpha = _currentUser.address != "" ? 1.0 : 0.4
        profileVerifiedButton.alpha = _currentUser.profileImage != "" ? 1.0 : 0.4
    }
    
    private func setupCollection() {
        sellingItemsCollectionView.dataSource = self
        sellingItemsCollectionView.delegate = self
        sellingItemsCollectionView.backgroundColor = .clear
        
        soldItemsCollectionView.dataSource = self
        soldItemsCollectionView.delegate = self
        soldItemsCollectionView.backgroundColor = .clear
        
        favsItemsCollectionView.dataSource = self
        favsItemsCollectionView.delegate = self
        favsItemsCollectionView.backgroundColor = .clear
    }
    
    private func setupLayout() {
//        sellingItemCollectionViewLayout.delegate = self
//        sellingItemCollectionViewLayout.cellPadding = 5
//        sellingItemCollectionViewLayout.numberOfColumns = 2
//
//        soldItemCollectionViewLayout.delegate = self
//        soldItemCollectionViewLayout.cellPadding = 5
//        soldItemCollectionViewLayout.numberOfColumns = 2
//
//        favItemCollectionViewLayout.delegate = self
//        favItemCollectionViewLayout.cellPadding = 5
//        favItemCollectionViewLayout.numberOfColumns = 2
        
        let layout1 = ETCollectionViewWaterfallLayout()
        layout1.minimumColumnSpacing = 15
        layout1.minimumInteritemSpacing = 15
        layout1.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        
        sellingItemsCollectionView.collectionViewLayout = layout1
        
        let layout2 = ETCollectionViewWaterfallLayout()
        layout2.minimumColumnSpacing = 15
        layout2.minimumInteritemSpacing = 15
        layout2.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        
        soldItemsCollectionView.collectionViewLayout = layout2
        
        let layout3 = ETCollectionViewWaterfallLayout()
        layout3.minimumColumnSpacing = 15
        layout3.minimumInteritemSpacing = 15
        layout3.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        
        favsItemsCollectionView.collectionViewLayout = layout3
    }
    
    @IBAction func closeBarButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    @IBAction func userDetailsButtonTapped(_ sender: Any) {
        if partiallyVerifiedViewHeightConstraint.constant == 0 {
            partiallyVerifiedViewHeightConstraint.constant = 140
            partiallyVerifiedView.isHidden = false
        } else {
            partiallyVerifiedViewHeightConstraint.constant = 0
            partiallyVerifiedView.isHidden = true
        }
    }
    
    @IBAction func sellingButtonTapped(_ sender: Any) {
        selectedType = .selling
    }
    
    @IBAction func soldButtonTapped(_ sender: Any) {
        selectedType = .sold
    }
    
    @IBAction func reviewButtonTapped(_ sender: Any) {
        selectedType = .reviews
    }
    
    @IBAction func faveButtonTapped(_ sender: Any) {
        selectedType = .faves
    }
    
    func resetSelectedButton() {
        [sellingButtonView, soldButtonView, reviewButtonView, faveButtonView].forEach { $0?.alpha = 0.5 }
        [sellingItemsCollectionView, soldItemsCollectionView, favsItemsCollectionView].forEach { $0?.isHidden = true }
    }
    
    @IBAction func settingBarButtonTapped(_ sender: Any) {
        let vc = XAPStoryboard.profileScene.editProfileVC()
        vc.viewModel = viewModel
        show(vc, sender: nil)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        var hud: MBProgressHUD? = nil
        rx.actionSheet(cancelTitle: "Cancel".localized, destructiveTitle: "Sign Out".localized, otherTitles: [], popoverConfig: PopoverConfig(source: .barButtonItem(moreBarButton)))
            .flatMap { [weak self] style, _ -> Observable<()> in
                guard let _self = self else { return Observable.empty() }
                guard style == .destructive else { return Observable.empty() }
                hud = _self.showActivityHUDTopMost()
                return _self.viewModel.signOut()
            }.subscribe { [weak self] evt in
                hud?.hide(animated: true)
                switch evt {
                case .next:
                    _ = self?.popViewController()
                case .error(let error):
                    print(error.localizedDescription)
                    self?.ext_messages.show(type: .error, body: "Failed to SignOut.".localized, vc: nil)
                default:
                    break
                }
        }.addDisposableTo(rx_disposeBag)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == sellingItemsCollectionView {
            return viewModel.sellingItems.count
        } else if collectionView == soldItemsCollectionView {
            return viewModel.soldItems.count
        } else {
            return viewModel.user.favItems.count
//            return AppContext.shared.currentUser!.favItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ItemCollectionViewCell
        
        let item: Item
        if collectionView == sellingItemsCollectionView {
            item = viewModel.sellingItems[indexPath.item]
        } else if collectionView == soldItemsCollectionView {
            item = viewModel.soldItems[indexPath.item]
        } else {
            item = viewModel.user.favItems[indexPath.item]
//            item = AppContext.shared.currentUser!.favItems[indexPath.item]
        }
        
        setupCell(cell: cell, indexPath: indexPath, item: item)
        return cell
    }
    
    func setupCell(cell: ItemCollectionViewCell, indexPath: IndexPath, item: Item) {
        var url: URL? = nil
        if item.pictureUrls.count > 0 {
            url = try? APIURL(stringLiteral: item.pictureUrls[0] ?? "").asPhotoURL()
        }
        
        cell.imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "item_placeholder"))
        cell.item = item
    }
}

extension ProfileViewController: ETCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let image = images[indexPath.item % 3]
        var height = image.height(forWidth: 100)
        
        var budget = ""
        var name = ""
        
        if collectionView == sellingItemsCollectionView {
            budget = "\(viewModel.sellingItems[indexPath.item].currency.rawValue) \(viewModel.sellingItems[indexPath.item].price)"
            name = viewModel.sellingItems[indexPath.item].title
        } else if collectionView == soldItemsCollectionView {
            budget = "\(viewModel.soldItems[indexPath.item].currency.rawValue) \(viewModel.soldItems[indexPath.item].price)"
            name = viewModel.soldItems[indexPath.item].title
        } else {
            budget = "\(viewModel.user.favItems[indexPath.item].currency.rawValue) \(viewModel.user.favItems[indexPath.item].price)"
            name = viewModel.user.favItems[indexPath.item].title
        }
        
        let budgetHeight = budget.heightForWidth(width: 100 - 16, font: UIFont.systemFont(ofSize: 23))
        let nameHeight = name.heightForWidth(width: 100 - 16, font: UIFont.systemFont(ofSize: 17))
        height += budgetHeight + nameHeight + 25
        
        return CGSize(width: 100, height: height)
    }
}

extension ProfileViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let image = images[indexPath.item % 3]
        
        return image.height(forWidth: withWidth)
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let budgetHeight = budget[indexPath.item % 3].heightForWidth(width: withWidth - 16, font: UIFont.systemFont(ofSize: 23))
        let nameHeight = itemName[indexPath.item % 3].heightForWidth(width: withWidth - 16, font: UIFont.systemFont(ofSize: 17))
        return budgetHeight + nameHeight + 24
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sellingItemsCollectionView {
            let vc = XAPStoryboard.profileScene.profileItemDetailVC()
            vc.item = viewModel.sellingItems[indexPath.item]
            show(vc, sender: nil)
        } else if collectionView == soldItemsCollectionView {
            let vc = XAPStoryboard.profileScene.profileItemDetailVC()
            vc.item = viewModel.soldItems[indexPath.item]
            show(vc, sender: nil)
        } else {
//            guard let item = AppContext.shared.currentUser?.favItems[indexPath.row] else { return }
            let item = viewModel.user.favItems[indexPath.row]
            let vc = XAPStoryboard.homeScene.itemDetailVC()
            let itemDetailViewModel = HomeViewModel()
            vc.item = item
            vc.viewModel = itemDetailViewModel
            show(vc, sender: nil)
        }
    }
}
