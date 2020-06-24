//
//  Sequence.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import TwitterTextEditor
import XCTest

final class SequenceTest: XCTestCase {
    func testForEachWithContinue() {
        let sequence = [1, 2, 3]

        let expectation = XCTestExpectation(description: "forEach")
        var results = [Int]()

        sequence.forEach(queue: DispatchQueue.global(), completion: {
            expectation.fulfill()
        }, { element, next in
            results.append(element)
            next(.continue)
        })

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(results, sequence)
    }

    func testForEachWithBreak() {
        let sequence = [1, 2, 3]

        let expectation = XCTestExpectation(description: "forEach")
        var results = [Int]()

        sequence.forEach(queue: DispatchQueue.global(), completion: {
            expectation.fulfill()
        }, { element, next in
            results.append(element)
            next(.break)
        })

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(results, [1])
    }

    func testForEachWithoutCompletion() {
        let sequence = [1, 2, 3]

        let expectation = XCTestExpectation(description: "forEach")
        var results = [Int]()

        sequence.forEach(queue: DispatchQueue.global()) { element, next in
            results.append(element)
            if results.count < sequence.count {
                next(.continue)
            } else {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(results, sequence)
    }

    func testForEachWithAsyncBody() {
        let sequence = [1, 2, 3]

        let expectation = XCTestExpectation(description: "forEach")
        var results = [Int]()

        sequence.forEach(queue: DispatchQueue.global(), completion: {
            expectation.fulfill()
        }, { element, next in
            DispatchQueue.global().async {
                results.append(element)
                next(.continue)
            }
        })

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(results, sequence)
    }
}
