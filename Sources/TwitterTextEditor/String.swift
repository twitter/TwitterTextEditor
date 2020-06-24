//
//  String.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
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
