//
//  PlaceholderData.swift
//  Pods
//
//  Created by Hamza Ghazouani on 20/07/2017.
//
//

import UIKit

/// Contains the placeholder data: texts, image, etc 
public struct PlaceholderData {
    
    // MARK: properties
    
    /// The placeholder image, if the image is nil, the placeholder image view will be hidden
    public var image: UIImage?
    
    /// the placeholder title
    public var title: String?
    
    /// The placeholder subtitle
    public var subtitle: String?
    
    /// The placehlder action title, if the action title is nil, the placeholder action button will be hidden
    public var action: String?
    
    /// Should shows the activity indicator of the placeholder or not
    public var showsLoading = false
    
    /// Should show action button
    public var showsAction = true
    
    // MARK: init methods
    
    
    /// Create and return PlaceholderData object
    public init() {}
    
    // MARK: Defaults placeholders data
    
    /// The default data (texts, image, ...) of the default no results placeholder
    public static var noResults: PlaceholderData {
        var noResultsStyle = PlaceholderData()
        noResultsStyle.image = PlaceholdersProvider.image(named: "hg_default-no_results")
        noResultsStyle.title = NSLocalizedString("No item founds".localized, comment: "")
        noResultsStyle.subtitle = NSLocalizedString("There is no items\nto show you.".localized, comment: "")
        noResultsStyle.action = NSLocalizedString("Try Again!".localized, comment: "")
        
        return noResultsStyle
    }
    
    /// The default data (texts, image, ...) of the default loading placeholder
    public static var loading: PlaceholderData {
        var loadingStyle = PlaceholderData()
        loadingStyle.image = PlaceholdersProvider.image(named: "hg_default-loading")
        loadingStyle.title = NSLocalizedString("Loading...".localized, comment: "")
        loadingStyle.action = NSLocalizedString("Cancel".localized, comment: "")
        loadingStyle.subtitle = NSLocalizedString("Loading will takes some time.".localized, comment: "")
        loadingStyle.showsLoading = true
        loadingStyle.showsAction = false
        
        return loadingStyle
    }
    
    /// The default data (texts, image, ...) of the default error placeholder
    public static var error: PlaceholderData {
        var errorStyle = PlaceholderData()
        errorStyle.image = PlaceholdersProvider.image(named: "hg_default-error")
        errorStyle.title = NSLocalizedString("Whoops!".localized, comment: "")
        errorStyle.subtitle = NSLocalizedString("We tried, but something went\nteriblly wrong".localized, comment: "")
        errorStyle.action = NSLocalizedString("Try Again!".localized, comment: "")
        
        return errorStyle
    }
    
    /// The default data (texts, image, ...) of the default no connecton placeholder
    public static var noConnection: PlaceholderData {
        var noConnectionStyle = PlaceholderData()
        noConnectionStyle.image = PlaceholdersProvider.image(named: "hg_default-no_connection")
        noConnectionStyle.title = NSLocalizedString("Whoops!".localized, comment: "")
        noConnectionStyle.subtitle = NSLocalizedString("Slow or no internet connections.\nPlease check your internet settings".localized, comment: "")
        noConnectionStyle.action = NSLocalizedString("Try Again!".localized, comment: "")
        
        return noConnectionStyle
    }
}
