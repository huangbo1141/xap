//
//  PickedMedia.swift
//  XAP
//
//  Created by Zhang Yi on 23/12/2015.
//  Copyright © 2015 JustTwoDudes. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices
import Photos
import RxSwift

/**
 MediaPickerResult
 */
enum PickedMedia {
    case photo(UIImage)
    case file(URL)
    case asset(PHAsset)
}

extension PickedMedia {
    var image:UIImage?{
        switch self {
        case let .photo(image):
            return image
        case let .file(url):
            guard let data = try? Data(contentsOf: url) else { return nil }
            return UIImage(data: data)
        default:
            return nil
        }
    }
}
