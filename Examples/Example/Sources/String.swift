//
//  String.swift
//  Example
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
    func substring(with range: NSRange) -> String {
        (self as NSString).substring(with: range)
    }

    func substring(with result: NSTextCheckingResult, at index: Int) -> String? {
        guard index < result.numberOfRanges else {
            return nil
        }
        let range = result.range(at: index)
        guard range.location != NSNotFound else {
            return nil
        }
        return substring(with: result.range(at: index))
    }

    func firstMatch(pattern: String,
                    options: NSRegularExpression.Options = [],
                    range: NSRange? = nil) -> NSTextCheckingResult?
    {
        guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: options) else {
            return nil
        }
        let range = range ?? NSRange(location: 0, length: length)
        return regularExpression.firstMatch(in: self, options: [], range: range)
    }

    func matches(pattern: String,
                 options: NSRegularExpression.Options = [],
                 range: NSRange? = nil) -> [NSTextCheckingResult]
    {
        guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: options) else {
            return []
        }
        let range = range ?? NSRange(location: 0, length: length)
        return regularExpression.matches(in: self, options: [], range: range)
    }
}
