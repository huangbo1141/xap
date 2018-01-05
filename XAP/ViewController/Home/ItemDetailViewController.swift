//
//  ItemDetailViewController.swift
//  XAP
//
//  Created by Alex on 15/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import ImageSlideshow
import RxSwift
import MapKit
import CoreLocation
import SwiftLocation
import FBSDKShareKit
import FBSDKLoginKit
import MessageUI
import Social
import Kingfisher

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var faveBarButton: UIBarButtonItem!
    @IBOutlet weak var slideShowImageView: ImageSlideshow!
    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var seenLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var posterNameLabel: UILabel!
    
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var acceptableTradesView: UIView!
    @IBOutlet weak var firmPriceView: UIView!
    @IBOutlet weak var shippingAvailableView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var reservedMarkView: UIView!
    @IBOutlet weak var soldMarkView: UIView!
    
    var slideViewPictures: [ImageSource] = [] {
        didSet {
            slideShowImageView.setImageInputs(slideViewPictures)
        }
    }
    
    var viewModel: HomeViewModel!
    var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initSlideshow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        initUI()
        viewModel.setSeen(item: item).subscribe().addDisposableTo(rx_disposeBag)
    }
    
    var isFav = false {
        didSet {
            faveBarButton.image = isFav ? #imageLiteral(resourceName: "ic_fav_fill") : #imageLiteral(resourceName: "ic_fav")
        }
    }
    
    func initSlideshow() {
        slideShowImageView.backgroundColor = UIColor.white
        slideShowImageView.slideshowInterval = 10.0
        slideShowImageView.pageControlPosition = PageControlPosition.insideScrollView
        slideShowImageView.pageControl.currentPageIndicatorTintColor = UIColor.black
        slideShowImageView.pageControl.pageIndicatorTintColor = UIColor.lightGray
        slideShowImageView.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didSlideshowImageViewTapped))
        slideShowImageView.addGestureRecognizer(recognizer)
    }
    
    func initUI() {
        slideViewPictures = []
        item.pictureUrls.enumerated().forEach { arg in
            let index = arg.offset
            guard let url = try? APIURL(stringLiteral: arg.element).asPhotoURL() else { return }
            
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, url in
                guard let _image = image else { return }
                self.slideViewPictures.append(ImageSource(image: _image))
            })
        }
//        let pictures = item.pictureUrls.map({ url -> UIImage? in
//
//            let data = try? Data(contentsOf: APIURL(stringLiteral: url).asPhotoURL())
//            if let imageData = data {
//                return UIImage(data: imageData)
//            }
//            return nil
//        }).filter { $0 != nil }.map { ImageSource(image: $0!) }
        
//        slideShowImageView.setImageInputs(pictures)
        
        priceLabel.text = "\(item.currency.rawValue) \(item.price)"
        titleLabel.text = item.title
        descriptionLabel.text = item.descriptionText
        updateDateLabel.text = item.updateTime.toDateString(format: "yyyy-MM-dd hh:mm")
        
        let annotation = MKPointAnnotation()
        let location = CLLocation(latitude: CLLocationDegrees(item.latitude), longitude: CLLocationDegrees(item.longitude))
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        
        Locator.location(fromCoordinates: location.coordinate, onSuccess: { (placemarks) -> (Void) in
            self.addressLabel.text = placemarks.first?.country
        }) { (error) -> (Void) in
            print(error.localizedDescription)
        }
        
        /*
        Locator.location.getPlacemark(forLocation: location, success: { placemarks in
            self.addressLabel.text = placemarks.first?.country
        }) { error in
            print(error.localizedDescription)
        }
        */
        avatarImageView.kf.setImage(with: try? APIURL(stringLiteral: item.user_?.profileImage ?? "").asPhotoURL(), placeholder: #imageLiteral(resourceName: "ic_face"))
        posterNameLabel.text = item.user_?.userName ?? ""
        
        if !item.isAcceptableTrades {
            acceptableTradesView.alpha = 0.5
        }
        
        if !item.isFirmPrice {
            firmPriceView.alpha = 0.5
        }
        
        if !item.isShippingAvailable {
            shippingAvailableView.alpha = 0.5
        }
        
        seenLabel.text = "\(item.seens + 1)"
        
        favCountLabel.text = "\(item.favUsers.count)"
        isFav = item.favUsers.contains { $0.id == AppContext.shared.userCredentials.userId }
        
        reservedMarkView.isHidden = !item.reserved || item.sold
        soldMarkView.isHidden = !item.sold
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSlideshowImageViewTapped() {
        let fullScreenController = slideShowImageView.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    @IBAction func favButtonTapped(_ sender: Any) {
        viewModel.setFav(item: item, isFav: isFav).subscribe(onNext: { [weak self] _ in
            guard let _self = self else { return }
            _self.isFav = !_self.isFav
            guard let newItem = try? Item.existingOrNew(in: AppContext.shared.mainContext, matching: Item.predicate(forId: _self.item.id)) else { return }
            _self.item = newItem
            _self.initUI()
        }, onError: {[weak self] error in
            if case APIError.login = error {
                let vc = XAPStoryboard.landingScene.landingVC()
                self?.modalPresentationStyle = .currentContext
                self?.present(vc, animated: true)
            }
        }).addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [contentView.capturedImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.mail, UIActivityType.message, UIActivityType.copyToPasteboard]
        
        self.present(activityViewController, animated: true)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        rx.actionSheet(cancelTitle: "Cancel", destructiveTitle: "Report this listing", popoverConfig: PopoverConfig(source: .barButtonItem(moreBarButton)))
            .subscribe(onNext: { [weak self] style, _ in
                guard let _self = self else { return }
                guard style != UIAlertActionStyle.cancel else { return }
                
                let vc = XAPStoryboard.homeScene.choosingReasonVC()
                vc.completeHandler = _self.reportItem
                _self.present(vc, animated: true)
            }).addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        if AppContext.shared.userCredentials.userId <= 0 || AppContext.shared.currentUser == nil {
            let vc = XAPStoryboard.landingScene.landingVC()
            self.modalPresentationStyle = .currentContext
            present(vc, animated: true)
        } else {
            let chattingViewModel = ChattingViewModel(itemId: item.id, userId: item.userId)
            let vc = ChatViewController(viewModel: chattingViewModel)
            show(vc, sender: nil)
        }
    }
    
    @IBAction func avatarImageTapped(_ sender: Any) {
        guard let user = item.user_ else { return }
        let vc = XAPStoryboard.profileScene.profileVC()
        vc.viewModel = ProfileViewModel(user: user)
        show(vc, sender: nil)
    }
    
    func reportItem(reason: ReportReason) {
        viewModel.reportItem(item: item, reason: reason).subscribe(onError: {[weak self] error in
            if case APIError.login = error {
                DispatchQueue.main.ext_asyncAfter(seconds: 0.5, execute: {
                    let vc = XAPStoryboard.landingScene.landingVC()
                    self?.modalPresentationStyle = .currentContext
                    self?.present(vc, animated: true)
                })
            }
        }).addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func twitterButtonTapped(_ sender: Any) {
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
        }
        
        let image = contentView.capturedImage
        
        let loginManager = FBSDKLoginManager()
//        loginManager.logOut()
        loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (loginResult, error) in
            guard error == nil else { return }
            
            let photo = FBSDKSharePhoto(image: image, userGenerated: true)
            let content = FBSDKSharePhotoContent()
            content.photos = [photo]
            
            let dialog = FBSDKShareDialog()
            dialog.fromViewController = self
            dialog.shareContent = content
            dialog.delegate = self
            dialog.mode = FBSDKShareDialogMode.shareSheet
            dialog.show()
//            FBSDKShareDialog.show(from: self, with: content, delegate: self)
        }
    }
    
    @IBAction func emailButtonTapped(_ sender: Any) {
        let mailComopserVC = MFMailComposeViewController()
        mailComopserVC.mailComposeDelegate = self
        
        //        mailComopserVC.setToRecipients("email")
        mailComopserVC.setSubject("Share listing on XAP".localized)
        
        let imageData = UIImageJPEGRepresentation(contentView.capturedImage, 0.5)
        let fileName = item.title + ".jpg"
        
        mailComopserVC.setMessageBody("<html><body><p>" + "This is Listing on XAP, shared by".localized + " \(AppContext.shared.currentUser!.userName)</p></body></html>", isHTML: true)
        mailComopserVC.addAttachmentData(imageData!, mimeType: "image/jpeg", fileName: fileName)
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComopserVC, animated: true)
        }
    }
}

extension ItemDetailViewController : FBSDKSharingDelegate {
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        
    }
}

extension ItemDetailViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
