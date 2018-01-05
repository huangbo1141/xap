import UIKit

protocol CountryPhoneCodePickerDelegate {
    func countryPhoneCodePicker(picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String)
}

struct Country {
    var code: String?
    var name: String?
    var phoneCode: String?
    
    init(code: String?, name: String?, phoneCode: String?) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
    }
    
    static func from(countryCode: String) -> Country? {
        guard NSLocale.isoCountryCodes.contains(countryCode) else { return nil }
        
        let countryName = (NSLocale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
        
        let phoneNumberUtil = NBPhoneNumberUtil.sharedInstance()!
        let phoneCode: String? = "+\(phoneNumberUtil.getCountryCode(forRegion: countryCode) ?? 0)"
        
        if phoneCode != "+0" {
            let country = Country(code: countryCode, name: countryName, phoneCode: phoneCode)
            return country
        }
        
        return nil
    }
}

class CountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countries: [Country]!
    var countryPhoneCodeDelegate: CountryPhoneCodePickerDelegate?
    
    var currentCountry: Country? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        super.dataSource = self;
        super.delegate = self;
        
        countries = countryNamesByCode()
    }
    
    // MARK: - Country Methods
    
    func setCountry(code: String) {
        var row = 0
        for index in 0..<countries.count {
            if countries[index].code == code {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
    }
    
    func countryNamesByCode() -> [Country] {
        var countries = [Country]()
        
        for code in NSLocale.isoCountryCodes {
            
            let countryName = (NSLocale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: code)
            
            let phoneNumberUtil = NBPhoneNumberUtil.sharedInstance()!
            let phoneCode: String? = "+\(phoneNumberUtil.getCountryCode(forRegion: code) ?? 0)"
            
            if phoneCode != "+0" {
                let country = Country(code: code, name: countryName, phoneCode: phoneCode)
                countries.append(country)
            }
        }
        
        countries = countries.sorted(by: { $0.name! < $1.name! })
        
        return countries
    }
    
    // MARK: - Picker Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var resultView: CountryView
        
        if view == nil {
            resultView = (Bundle.main.loadNibNamed("CountryView", owner: self, options: nil)![0] as! CountryView)
        } else {
            resultView = view as! CountryView
        }
        
        resultView.setup(country: countries[row])
        
        return resultView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = countries[row]
        currentCountry = country
        if let countryPhoneCodeDelegate = countryPhoneCodeDelegate {
            countryPhoneCodeDelegate.countryPhoneCodePicker(picker: self, didSelectCountryCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!)
        }
    }
}
