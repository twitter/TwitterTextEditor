//
//  NSRangeTests.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation
@testable import TwitterTextEditor
import XCTest

final class NSRangeTests: XCTestCase {
    // |0|1|2|3|4|5|6|
    //     |-----|
    // |=|
    func testRangeWithLengthMovedByReplacingRangeWithLengthRangeBelowLowerBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 0, length: 1), length: 0),
            NSRange(location: 1, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 0, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 0, length: 1), length: 2),
            NSRange(location: 3, length: 3)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //   |
    func testRangeWithLengthMovedByReplacingRangeWithoutLengthBelowLowerBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 0), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 0), length: 1),
            NSRange(location: 3, length: 3)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //   |=|
    func testRangeWithLengthMovedByReplacingRangeWithLengthAtLowerBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 1), length: 0),
            NSRange(location: 1, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 1), length: 2),
            NSRange(location: 3, length: 3)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //     |
    func testRangeWithLengthMovedByReplacingRangeWithoutLengthAtLowerBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 2, length: 0), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 2, length: 0), length: 1),
            NSRange(location: 3, length: 3)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //   |===|
    func testRangeWithLengthMovedByReplacingRangeWithLengthOverLowerBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 2), length: 1),
            NSRange(location: 1, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 2), length: 2),
            NSRange(location: 1, length: 4)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 1, length: 2), length: 3),
            NSRange(location: 1, length: 5)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //     |=|
    func testRangeWithLengthMovedByReplacingRangeWithLengthAtLowerBoundInBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 2, length: 1), length: 0),
            NSRange(location: 2, length: 2)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 2, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 2, length: 1), length: 2),
            NSRange(location: 2, length: 4)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //       |
    func testRangeWithLengthMovedByReplacingRangeWithoutLengthAtLowerInBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 3, length: 0), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 3, length: 0), length: 1),
            NSRange(location: 2, length: 4)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //       |=|
    func testRangeWithLengthMovedByReplacingRangeWithLengthInBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 3, length: 1), length: 0),
            NSRange(location: 2, length: 2)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 3, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 3, length: 1), length: 2),
            NSRange(location: 2, length: 4)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //         |
    func testRangeWithLengthMovedByReplacingRangeWithoutLengthAtUpperInBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 0), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 0), length: 1),
            NSRange(location: 2, length: 4)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //         |=|
    func testRangeWithLengthMovedByReplacingRangeWithLengthAtUpperBoundInBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 1), length: 0),
            NSRange(location: 2, length: 2)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 1), length: 2),
            NSRange(location: 2, length: 4)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //         |===|
    func testRangeWithLengthMovedByReplacingRangeWithLengthOverUpperBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 2), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 2), length: 2),
            NSRange(location: 2, length: 4)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 4, length: 2), length: 3),
            NSRange(location: 2, length: 5)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //           |
    func testRangeWithLengthMovedByReplacingRangeWithoutLengthAtUpperBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 5, length: 0), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 5, length: 0), length: 1),
            NSRange(location: 2, length: 3)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //           |=|
    func testRangeWithLengthMovedByReplacingRangeWithLengthAtUpperBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 5, length: 1), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 5, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 5, length: 1), length: 2),
            NSRange(location: 2, length: 3)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //             |
    func testRangeWithLengthMovedByReplacingRangeWithoutLengthAboveUpperBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 6, length: 1), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 6, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 6, length: 1), length: 2),
            NSRange(location: 2, length: 3)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |-----|
    //             |=|
    func testRangeWithLengthMovedByReplacingRangeWithLengthAboveUpperBound() {
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 6, length: 1), length: 0),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 6, length: 1), length: 1),
            NSRange(location: 2, length: 3)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 3).movedByReplacing(range: NSRange(location: 6, length: 1), length: 2),
            NSRange(location: 2, length: 3)
        )
    }

    // MARK: -

    // |0|1|2|3|4|5|6|
    // |
    //   |=======|
    func testRangeWithoutLengthBelowLowerBoundMovedByReplacingRange() {
        XCTAssertEqual(
            NSRange(location: 0, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 0),
            NSRange(location: 0, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 0, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 4),
            NSRange(location: 0, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 0, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 8),
            NSRange(location: 0, length: 0)
        )
    }

    // |0|1|2|3|4|5|6|
    //   |
    //   |=======|
    func testRangeWithoutLengthOnLowerBoundMovedByReplacingRange() {
        XCTAssertEqual(
            NSRange(location: 1, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 0),
            NSRange(location: 1, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 1, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 4),
            NSRange(location: 1, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 1, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 8),
            NSRange(location: 1, length: 0)
        )
    }

    // |0|1|2|3|4|5|6|
    //     |
    //   |=======|
    func testRangeWithoutLengthInBoundBelowMiddleMovedByReplacingRange() {
        XCTAssertEqual(
            NSRange(location: 2, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 0),
            NSRange(location: 1, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 4),
            NSRange(location: 1, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 2, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 8),
            NSRange(location: 1, length: 0)
        )
    }

    // |0|1|2|3|4|5|6|
    //       |
    //   |=======|
    func testRangeWithoutLengthInBoundAtMiddleMovedByReplacingRange() {
        XCTAssertEqual(
            NSRange(location: 3, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 0),
            NSRange(location: 1, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 3, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 4),
            NSRange(location: 5, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 3, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 8),
            NSRange(location: 9, length: 0)
        )
    }

    // |0|1|2|3|4|5|6|
    //         |
    //   |=======|
    func testRangeWithoutLengthInBoundAboveMiddleMovedByReplacingRange() {
        XCTAssertEqual(
            NSRange(location: 4, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 0),
            NSRange(location: 1, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 4, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 4),
            NSRange(location: 5, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 4, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 8),
            NSRange(location: 9, length: 0)
        )
    }

    // |0|1|2|3|4|5|6|
    //           |
    //   |=======|
    func testRangeWithoutLengthOnUpperBoundMovedByReplacingRange() {
        XCTAssertEqual(
            NSRange(location: 5, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 0),
            NSRange(location: 1, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 5, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 4),
            NSRange(location: 5, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 5, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 8),
            NSRange(location: 9, length: 0)
        )
    }

    // |0|1|2|3|4|5|6|
    //             |
    //   |=======|
    func testRangeWithoutLengthAboveUpperBoundMovedByReplacingRange() {
        XCTAssertEqual(
            NSRange(location: 6, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 0),
            NSRange(location: 2, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 6, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 4),
            NSRange(location: 6, length: 0)
        )
        XCTAssertEqual(
            NSRange(location: 6, length: 0).movedByReplacing(range: NSRange(location: 1, length: 4), length: 8),
            NSRange(location: 10, length: 0)
        )
    }
}
