//
//  ProfileItemDetailViewController.swift
//  XAP
//
//  Created by Alex on 18/9/2017.
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

class ProfileItemDetailViewController: UIViewController {

    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var moreBarButton: UIBarButtonItem!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    
    @IBOutlet weak var slideShowImageView: ImageSlideshow!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var acceptableTradesView: UIView!
    @IBOutlet weak var firmPriceView: UIView!
    @IBOutlet weak var shippingAvailableView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    
    @IBOutlet weak var reservedMarkView: UIView!
    @IBOutlet weak var soldMarkView: UIView!
 
    @IBOutlet weak var titleOffsetConstraint: NSLayoutConstraint!
    
    var item: Item!
    
    var isReserved = false {
        didSet {
            if isReserved == true {
                reserveButton.setTitleColor(UIColor(hexString: "0080FF"), for: .normal)
                reserveButton.backgroundColor = .lightGray
                reserveButton.setTitle("Unreserve", for: .normal)
                reservedMarkView.isHidden = false
            } else {
                reserveButton.setTitleColor(.white, for: .normal)
                reserveButton.backgroundColor = UIColor(hexString: "0080FF")
                reserveButton.setTitle("Reserve", for: .normal)
                reservedMarkView.isHidden = true
            }
        }
    }
    
    var slideViewPictures: [ImageSource] = [] {
        didSet {
            slideShowImageView.setImageInputs(slideViewPictures)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initSlideshow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initUI()
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
//            let data = try? Data(contentsOf: APIURL(stringLiteral: url).asPhotoURL())
//            if let imageData = data {
//                return UIImage(data: imageData)
//            }
//            return nil
//        }).filter { $0 != nil }.map { ImageSource(image: $0!) }
//
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
        IPLocationRequest.getPlacemark(forLocation: location, success: { placemarks in
            self.addressLabel.text = placemarks.first?.country
        }) { error in
            print(error.localizedDescription)
        }
        */
        if !item.isAcceptableTrades {
            acceptableTradesView.alpha = 0.5
        }
        
        if !item.isFirmPrice {
            firmPriceView.alpha = 0.5
        }
        
        if !item.isShippingAvailable {
            shippingAvailableView.alpha = 0.5
        }
        
        isReserved = item.reserved
        
        reservedMarkView.isHidden = !item.reserved
        soldMarkView.isHidden = !item.sold
        
        if item.sold {
            reserveButton.isHidden = true
            soldButton.isHidden = true
            titleOffsetConstraint.constant = 16
            
            self.navigationItem.rightBarButtonItems?.removeLast()
        }
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
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [contentView.capturedImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.mail, UIActivityType.message, UIActivityType.copyToPasteboard]
        
        self.present(activityViewController, animated: true)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        rx.actionSheet(cancelTitle: "Cancel", destructiveTitle: "Delete listing", popoverConfig: PopoverConfig(source: .barButtonItem(moreBarButton)))
            .subscribe(onNext: { [weak self] style, _ in
                guard let _self = self else { return }
                guard style != UIAlertActionStyle.cancel else { return }
                _self.deleteItem()
            }).addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let vc = XAPStoryboard.postScene.postItemVC()
        vc.item = item
        present(vc, animated: true)
    }
    
    func deleteItem() {
        let hud = showActivityHUDTopMost()
        ItemManager.default.deleteItem(item: item).subscribe(onNext: { [weak self] _ in
            hud.hide(animated: false)
            _ = self?.popViewController()
        }).addDisposableTo(rx_disposeBag)
    }
    @IBAction func reserveButtonTapped(_ sender: Any) {
        ItemManager.default.reserveItem(item: item, isReserved: !item.reserved).subscribe(onNext: { [weak self] _ in
            guard let _self = self else { return }
            _self.isReserved = !_self.isReserved
        }).addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        ItemManager.default.sellItem(item: item).subscribe().addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func facebookTapped(_ sender: Any) {
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
    
    @IBAction func emailTapped(_ sender: Any) {
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

extension ProfileItemDetailViewController : FBSDKSharingDelegate {
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        
    }
}

extension ProfileItemDetailViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
