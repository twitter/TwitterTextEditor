//
//  NSRange.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

extension NSRange {
    static var zero: NSRange = NSRange(location: 0, length: 0)

    static var null: NSRange = NSRange(location: NSNotFound, length: 0)

    /**
     Reasonably move range for selection in text by replacing the range with length.
     See unit tests for the actual behavior.

     - Parameters:
       - range: a range to be replaced.
       - length: a length that is replacing the `range`.

     - Returns:
       - Moved range for selection.
     */
    public func movedByReplacing(range: NSRange, length: Int) -> NSRange {
        // Intentionally explicitly using `self` in this function implementation to reduce confusion.

        let replacingRange = NSRange(location: range.location, length: length)
        let changeInLength = replacingRange.length - range.length

        if range.upperBound <= self.lowerBound {
            return NSRange(location: self.location + changeInLength, length: self.length)
        }

        if self.upperBound <= range.lowerBound {
            return self
        }

        let lowerBound = min(self.lowerBound, range.lowerBound)
        let upperBound = max(self.upperBound, range.upperBound)

        if self.length == 0 {
            let middleBound = (upperBound - lowerBound) / 2 + lowerBound
            if self.location < middleBound {
                return NSRange(location: lowerBound, length: self.length)
            } else {
                return NSRange(location: upperBound + changeInLength, length: self.length)
            }
        }

        return NSRange(location: lowerBound, length: upperBound - lowerBound + changeInLength)
    }

    @inlinable
    func contains(_ range: NSRange) -> Bool {
        lowerBound <= range.lowerBound && range.upperBound <= upperBound
    }
}
