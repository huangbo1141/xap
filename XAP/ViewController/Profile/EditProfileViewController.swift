//
//  EditProfileViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import RxSwift
import Kingfisher

class EditProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: DatePickerField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderSegment: BetterSegmentedControl!
    
    let imagePicker = SimpleImagePickerController(config: .profileImage)
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initGenderSegment()
        initBinding()
        _ = try? genderSegment.setIndex(UInt(viewModel.gender.rawValue))
        if let _avatarImage = viewModel.profileImage {
            avatarImageView.image = _avatarImage
        }
    }
    
    func initGenderSegment() {
        genderSegment.cornerRadius = 5
        genderSegment.indicatorViewBackgroundColor = .lightGray
        genderSegment.indicatorViewInset = 3.0
        genderSegment.titleColor = .lightGray
        genderSegment.selectedTitleColor = UIColor(hexString: "0F9CFF")
        genderSegment.backgroundColor = .clear
        genderSegment.layer.borderWidth = 2
        genderSegment.layer.borderColor = UIColor.lightGray.cgColor
        genderSegment.titles = ["MALE".localized, "FEMALE".localized]
        genderSegment.alwaysAnnouncesValue = true
        genderSegment.announcesValueImmediately = false
        _ = try? genderSegment.setIndex(0)
        genderSegment.addTarget(self, action: #selector(genderSegmentValueChanged(_:)), for: .valueChanged)
    }
    
    func initBinding() {
        firstNameTextField.rx.text.orEmpty <-> viewModel.firstName
        lastNameTextField.rx.text.orEmpty <-> viewModel.lastName
        birthdayTextField.rx.text.orEmpty <-> viewModel.birthday
        addressTextField.rx.text.orEmpty <-> viewModel.address
        viewModel.email.asObservable().bind(to: emailLabel.rx.text).addDisposableTo(rx_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func genderSegmentValueChanged(_ sender: BetterSegmentedControl) {
        viewModel.gender = Gender(rawValue: Int(genderSegment.index)) ?? .male
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let hud = showActivityHUDTopMost()
        viewModel.updateProfile().subscribe { [weak self] evt in
            hud.hide(animated: true)
            guard let _self = self else { return }
            switch evt {
            case .next:
                _self.ext_messages.show(type: .success, body: "Succeed to update profile".localized, vc: nil)
            case .error(let error):
                print(error.localizedDescription)
                _self.ext_messages.show(type: .error, body: "Failed to update profile".localized, vc: nil)
            default:
                break
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func changeEmailButtonTapped(_ sender: Any) {
        rx.textInput(title: "Email".localized, message: "Change email".localized, okTitle: "OK".localized, cancelTitle: "Cancel".localized) { string -> Bool in
            return string.isValidEmail
        }.subscribe(onNext: { email in
            guard let _email = email else { return }
            self.viewModel.email.value = email!
        }).addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func backBarButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    @IBAction func changePhotoButtonTapped(_ sender: Any) {
        let pickerType: [MediaPickerType] = [.cameraRollImage, .takePhoto]
        rx.actionSheet(title: "Select Source".localized, cancelTitle: "Cancel".localized,
                       otherTitles: ["Camera Roll".localized, "Take Photo".localized],
                       popoverConfig: PopoverConfig(source: .view(avatarImageView)))
            .filter { result in
                return result.style == .default
        }.flatMapLatest { [weak self] result -> Observable<PickedMedia?> in
            guard let _self = self else { return Observable.empty() }
            return _self.imagePicker.rx.pick(from: _self, type: pickerType[result.buttonIndex])
        }.filterNil()
        .subscribe(onNext: { media in
            guard case let .photo(image) = media else { return }
            self.avatarImageView.image = image
            self.viewModel.profileImage = image
        }).addDisposableTo(rx_disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_to_notification_settings":
            (segue.destination as! NotificationSettingViewController).viewModel = viewModel
        case "segue_to_category_settings":
            (segue.destination as! FavoriteCategoryViewController).viewModel = viewModel
        case "segue_to_verification_settings":
            (segue.destination as! VerifyingViewController).viewModel = viewModel
        default:
            break
        }
    }
}
