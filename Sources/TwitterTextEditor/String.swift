//
//  String.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

extension String {
    @inlinable
    var length: Int {
        (self as NSString).length
    }

    @inlinable
    var range: NSRange {
        NSRange(location: 0, length: length)
    }

    @inlinable
    func replacingCharacters(in range: NSRange, with replacement: String) -> String {
        (self as NSString).replacingCharacters(in: range, with: replacement)
    }

    @inlinable
    func substring(with range: NSRange) -> String {
        (self as NSString).substring(with: range)
    }
}
