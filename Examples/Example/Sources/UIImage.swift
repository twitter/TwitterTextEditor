//
//  UIImage.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

extension UIImage {
    static func animatedImage(named: NSDataAssetName, duration: TimeInterval) -> UIImage? {
        guard let dataAsset = NSDataAsset(name: named),
            let source = CGImageSourceCreateWithData(dataAsset.data as CFData, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)

        var images = [UIImage]()
        for index in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                return nil
            }
            let image = UIImage(cgImage: cgImage)
            images.append(image)
        }

        return .animatedImage(with: images, duration: duration)
    }
}
