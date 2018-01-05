//
//  Definitions.swift
//  XAP
//
//  Created by Alex on 6/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation

let isTesting = false

enum Gender : Int {
    case male = 0
    case female = 1
    
    var string: String {
        switch self {
        case .male:
            return "Male".localized
        case .female:
            return "Female".localized
        }
    }
    static var all : [Gender] = [.male, .female]
}

enum SideMenu {
    case profile
    case chat
    case bulletin
    case category(Category)
    case invite
    case help
}

enum Currency: String {
    case cny = "CNY"
    case ars = "ARS"
    case mxn = "MXN"
    case cop = "COP"
    case eur = "€"
    case usd = "$"
    case gbp = "£"
    case brl = "BRL"
    
    var index: Int {
        return Currency.all.index(of: self) ?? -1
    }
    
    static var all: [Currency] = [.cny, .ars, .mxn, .cop, .eur, .usd, .gbp, .brl]
    
    static func from(index: Int) -> Currency {
        return Currency.all[index]
    }
}

enum Category: String {
    case motorsAndAccessories = "Motors & Accessories"
    case electronics = "Electronics"
    case sportsAndLeisure = "Sports & Leisure"
    case homeAndGarden = "Home & Garden"
    case gamesAndConsoles = "Games & Consoles"
    case booksMoviesAndMusic = "Books, Movies & Music"
    case fashionAndAccessories = "Fashion & Accessories"
    case babyAndChild = "Baby & Child"
    case realEstate = "Real Estate"
    case appliances = "Appliances"
    case services = "Services"
    case other = "Other"
    
    var index: Int {
        return Category.all.index(of: self) ?? -1
    }
    
    static var all: [Category] = [.motorsAndAccessories, .electronics, .sportsAndLeisure, .homeAndGarden, .gamesAndConsoles,.booksMoviesAndMusic, .fashionAndAccessories, .babyAndChild, .realEstate, .appliances, .services, .other]
    
    static func from(index: Int) -> Category {
        return Category.all[index]
    }
}

enum TermsItem: Int {
    case acceptableTrade = 0
    case firmPrice = 1
    case shippingAvailable = 2
    
    var text: String {
        switch self {
        case .acceptableTrade:
            return "Accepts Trade".localized
        case .firmPrice:
            return "Firm Price".localized
        case .shippingAvailable:
            return "Shipping Available".localized
        }
    }
    
    var icon: UIImage {
        switch self {
        case .acceptableTrade:
            return #imageLiteral(resourceName: "ic_accept_black")
        case .firmPrice:
            return #imageLiteral(resourceName: "ic_dollar_black")
        case .shippingAvailable:
            return #imageLiteral(resourceName: "ic_vehicle_black")
        }
    }
    
    static var all: [TermsItem] = [.acceptableTrade, .firmPrice, .shippingAvailable]
}

enum SortBy: Int {
    case distance = 0
    case priceLowToHigh = 1
    case priceHightToLow = 2
    case mostRecent = 3
    
    var icon: UIImage {
        switch self {
        case .distance:
            return #imageLiteral(resourceName: "ic_position")
        case .priceLowToHigh:
            return #imageLiteral(resourceName: "ic_price_high")
        case .priceHightToLow:
            return #imageLiteral(resourceName: "ic_price_low")
        case .mostRecent:
            return #imageLiteral(resourceName: "ic_most_recent")
        }
    }
    
    var string: String {
        switch self {
        case .distance:
            return "Distance".localized
        case .priceLowToHigh:
            return "Price low to high".localized
        case .priceHightToLow:
            return "Price high to low".localized
        case .mostRecent:
            return "Most recently published".localized
        }
    }
    
    static var all: [SortBy] = [.distance, .priceLowToHigh, .priceHightToLow, .mostRecent]
}

enum ReportReason: Int {
    case peopleOrAnimals = 0
    case joke = 1
    case fakeItem = 2
    case explicitContent = 3
    case photoDontMatch = 4
    case foodOrDrinks = 5
    case drugsOrMedicines = 6
    case doubleItem = 7
    case forbiddenProductOrService = 8
    case resale = 9
    case spam = 10
    
    var string: String {
        switch self {
        case .peopleOrAnimals:
            return "People or animals".localized
        case .joke:
            return "Joke".localized
        case .fakeItem:
            return "Fake item".localized
        case .explicitContent:
            return "Explicit content".localized
        case .photoDontMatch:
            return "Photo doesn't match".localized
        case .foodOrDrinks:
            return "Food or drinks".localized
        case .drugsOrMedicines:
            return "Drugs or medicines".localized
        case .doubleItem:
            return "Doubled item".localized
        case .forbiddenProductOrService:
            return "Forbidden product or service".localized
        case .resale:
            return "Resale (tickets, etc)".localized
        case .spam:
            return "Spam".localized
        }
    }
    
    static var all: [ReportReason] = [.peopleOrAnimals, .joke, .explicitContent, .photoDontMatch, .foodOrDrinks, .drugsOrMedicines, .doubleItem, .forbiddenProductOrService, .resale, .spam]
}
