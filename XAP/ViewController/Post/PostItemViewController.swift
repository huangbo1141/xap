//
//  PostItemViewController.swift
//  XAP
//
//  Created by Alex on 15/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import RxSwift

class PostItemViewController: UIViewController {

    @IBOutlet weak var currencyPickerField: PickerTextField!
    @IBOutlet weak var termsVisibleView: UIView!
    
    @IBOutlet weak var picture1ImageView: UIImageView!
    @IBOutlet weak var picture2ImageView: UIImageView!
    @IBOutlet weak var picture3ImageView: UIImageView!
    @IBOutlet weak var picture4ImageView: UIImageView!
    
    var pictures: [UIImage?] = [nil, nil, nil, nil]
    
    @IBOutlet weak var shippingAvailableView: UIView!
    @IBOutlet weak var firmPriceView: UIView!
    @IBOutlet weak var acceptableTradeView: UIView!
    
    @IBOutlet weak var titleTextField: CustomFloatingTextField!
    @IBOutlet weak var descriptionTextField: CustomFloatingTextField!
    @IBOutlet weak var priceTextField: CustomFloatingTextField!
    @IBOutlet weak var categoryTextField: FloatingPickerTextField!
    
    @IBOutlet weak var listItemButton: UIButton!
    
    var itemTitle = ""
    
    let imagePicker = SimpleImagePickerController(config: .profileImage)
    
    let viewModel = PostItemViewModel()
    
    var item: Item? = nil
    
    var isShippingAvailable = false {
        didSet {
            if isShippingAvailable {
                shippingAvailableView.alpha = 1.0
            } else {
                shippingAvailableView.alpha = 0.5
            }
            
            viewModel.isShippingAvailable = isShippingAvailable
        }
    }
    
    var isFirmPrice = false {
        didSet {
            if isFirmPrice {
                firmPriceView.alpha = 1.0
            } else {
                firmPriceView.alpha = 0.5
            }
            
            viewModel.isFirmPrice = isFirmPrice
        }
    }
    
    var isAcceptableTrades = false {
        didSet {
            if isAcceptableTrades {
                acceptableTradeView.alpha = 1.0
            } else {
                acceptableTradeView.alpha = 0.5
            }
            
            viewModel.isAcceptableTrades = isAcceptableTrades
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currencyPickerField.pickerDataSource = Currency.all.map { $0.rawValue }
        categoryTextField.pickerDataSource = Category.all.map { $0.rawValue.localized }
        
        initBinding()
        
        if let _item = item {
            itemTitle = _item.title
            viewModel.title.value = _item.title
            viewModel.description.value = _item.descriptionText
            viewModel.price.value = "\(_item.price)"
            viewModel.currency.value = "\(_item.currency.rawValue)"
            viewModel.category.value = "\(_item.category.rawValue.localized)"
            
            isShippingAvailable = _item.isShippingAvailable
            isFirmPrice = _item.isFirmPrice
            isAcceptableTrades = _item.isAcceptableTrades
            
            var index = 0
            zip([picture1ImageView, picture2ImageView, picture3ImageView, picture4ImageView], _item.pictureUrls)
                .forEach({ imageView, url in
                    imageView?.kf.setImage(with: try? APIURL(stringLiteral: url).asPhotoURL(), placeholder: #imageLiteral(resourceName: "ic_item_photo_placeholder"), completionHandler: { image, _, _, _ in
                            self.pictures[index] = image
                            index += 1
                    })
                })
            
            listItemButton.setTitle("Update item".localized, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.title.value = itemTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initBinding() {
        titleTextField.rx.text.orEmpty <-> viewModel.title
        descriptionTextField.rx.text.orEmpty <-> viewModel.description
        priceTextField.rx.text.orEmpty <-> viewModel.price
        currencyPickerField.rx.text.orEmpty <-> viewModel.currency
        categoryTextField.rx.text.orEmpty <-> viewModel.category
    }
    
    @IBAction func currencyPickerFieldDropdownButtonTapped(_ sender: Any) {
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if item == nil {
            navigationController?.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func listItemButtonTapped(_ sender: Any) {        
        viewModel.pictures = pictures
        
        guard pictures.filter({ $0 != nil }).count > 0 else {
            ext_messages.show(type: .warning, body: "You have to add at least one picture.".localized, vc: nil)
            return
        }
        
        let ob: Observable<()>
        
        if item == nil {
            guard let obb = viewModel.listItem() else {
                return
            }
            ob = obb
//            let p = viewModel.category.value;
//            let c = Category(rawValue: viewModel.category.value)
//            debugPrint(p)
//            debugPrint(c)
//            let t = Category.all.map { $0.rawValue.localized }
//            if let index = t.index(of: p){
//                let cat = Category.all[index]
//                debugPrint(t)
//                debugPrint(cat)
//            }
            
//            Category cat = Category(rawValue: <#T##String#>)
            
        } else {
            guard let obb = viewModel.updateItem(itemId: item!.id) else {
                return
            }
            ob = obb
        }
        
        let hud = showActivityHUDTopMost()
        ob.subscribe {[weak self] evt in
            hud.hide(animated: true)
            guard let _self = self else { return }
            switch evt {
            case .next:
                _self.navigationController?.dismiss(animated: true)
                _self.ext_messages.show(type: .success, body: "Successed listing item".localized, vc: nil)
            case .error(let error):
                print(error.errorMessage(message: "Listing Item ERROR!"))
                _self.ext_messages.show(type: .error, body: error.errorMessage(message: "Failed listing item".localized), vc: nil)
            default:
                break
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func picture1ButtonTapped(_ sender: Any) {
        pickItemPicture(imageView: picture1ImageView, index: 0)
    }
    
    @IBAction func picture2ButtonTapped(_ sender: Any) {
        pickItemPicture(imageView: picture2ImageView, index: 1)
    }
    
    @IBAction func picture3ButtonTapped(_ sender: Any) {
        pickItemPicture(imageView: picture3ImageView, index: 2)
    }
    
    @IBAction func picture4ButtonTapped(_ sender: Any) {
        pickItemPicture(imageView: picture4ImageView, index: 3)
    }
    
    @IBAction func shippingAvailableButtonTapped(_ sender: Any) {
        isShippingAvailable = !isShippingAvailable
    }
    
    @IBAction func firmPriceButtonTapped(_ sender: Any) {
        isFirmPrice = !isFirmPrice
    }
    
    @IBAction func acceptableTradeButtonTapped(_ sender: Any) {
        isAcceptableTrades = !isAcceptableTrades
    }
    
    func pickItemPicture(imageView: UIImageView, index: Int) {
        let pickerType: [MediaPickerType] = [.cameraRollImage, .takePhoto]
        rx.actionSheet(title: "Select Source".localized, cancelTitle: "Cancel".localized,
                       otherTitles: ["Camera Roll".localized, "Take Photo".localized],
                       popoverConfig: PopoverConfig(source: .view(picture1ImageView)))
            .filter { result in
                return result.style == .default
            }.flatMapLatest { [weak self] result -> Observable<PickedMedia?> in
                guard let _self = self else { return Observable.empty() }
                return _self.imagePicker.rx.pick(from: _self, type: pickerType[result.buttonIndex])
            }.filterNil()
            .subscribe(onNext: { media in
                guard case let .photo(image) = media else { return }
                imageView.image = image
                self.pictures[index] = image
            }).addDisposableTo(rx_disposeBag)
    }
}
