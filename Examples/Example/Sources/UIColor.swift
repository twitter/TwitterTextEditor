//
//  UIColor.swift
//  Example
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    @objc(defaultTextColor)
    static var defaultText: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    @objc(defaultBackgroundColor)
    static var defaultBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    @objc(defaultBorderColor)
    static var defaultBorder: UIColor {
        if #available(iOS 13.0, *) {
            return .separator
        } else {
            return .systemGray
        }
    }
}
