//
//  PhotoExtension.swift
//  draft1
//
//  Created by Claire Mo on 7/6/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import Foundation
import Photos
import UIKit
//from internet
extension PHAsset {

    func image(completionHandler: @escaping (UIImage) -> ()){
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil, resultHandler: { img, _ in
            thumbnail = img!
        })
        completionHandler(thumbnail)
    }
}
