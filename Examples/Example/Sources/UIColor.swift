//
//  UIColor.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
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
