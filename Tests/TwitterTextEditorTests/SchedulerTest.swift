//
//  SchedulerTest.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import TwitterTextEditor
import XCTest

private protocol Runner {
    func perform(_: @escaping () -> Void)
}

extension RunLoop: Runner {
}

extension DispatchQueue: Runner {
    func perform(_ block: @escaping () -> Void) {
        async(execute: block)
    }
}

private extension Collection {
    subscript(optional index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension Result {
    var success: Success? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }

    var failure: Failure? {
        switch self {
        case .failure(let value):
            return value
        default:
            return nil
        }
    }
}

final class SchedulerTest: XCTestCase {
    private func wait(for runner: Runner) {
        let expectation = XCTestExpectation(description: String(describing: runner))
        runner.perform {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: -

    func testDebounceSchedulerShouldPerformScheduleOnce() {
        var performedCount = 0
        let scheduler = DebounceScheduler {
            performedCount += 1
        }

        scheduler.schedule()
        scheduler.schedule()

        XCTAssertEqual(performedCount, 0)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
    }

    func testDebounceSchedulerShouldPerform() {
        var performedCount = 0
        let scheduler = DebounceScheduler {
            performedCount += 1
        }

        scheduler.schedule()
        scheduler.perform()

        XCTAssertEqual(performedCount, 1)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
    }

    func testDebounceSchedulerShouldPerformScheduleAfterPerform() {
        var performedCount = 0
        let scheduler = DebounceScheduler {
            performedCount += 1
        }

        scheduler.schedule()
        scheduler.perform()
        scheduler.schedule()

        XCTAssertEqual(performedCount, 1)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 2)
    }

    // MARK: -

    func testContentFilterSchedulerShouldPerformOnce() {
        var performedCount = 0
        let scheduler = ContentFilterScheduler<String, String> { input, completion in
            performedCount += 1
            completion(.success(input))
        }

        var results = [Result<String, Error>]()
        let completion = { (result: Result<String, Error>) -> Void in
            results.append(result)
        }

        scheduler.schedule("meow", completion: completion)
        scheduler.schedule("purr", completion: completion)

        XCTAssertEqual(performedCount, 0)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[optional: 0]?.failure as? SchedulerError, .cancelled)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[optional: 1]?.success, "purr")
    }

    func testContentFilterSchedulerShouldUseCache() {
        var performedCount = 0
        let scheduler = ContentFilterScheduler<String, String> { input, completion in
            performedCount += 1
            completion(.success(input))
        }

        var results = [Result<String, Error>]()
        let completion = { (result: Result<String, Error>) -> Void in
            results.append(result)
        }

        scheduler.schedule("meow", completion: completion)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[optional: 0]?.success, "meow")

        scheduler.schedule("meow", completion: completion)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[optional: 1]?.success, "meow")
    }

    func testContentFilterSchedulerShouldPerformOnceAndUseCache() {
        var performedCount = 0
        let scheduler = ContentFilterScheduler<String, String> { input, completion in
            performedCount += 1
            completion(.success(input))
        }

        var results = [Result<String, Error>]()
        let completion = { (result: Result<String, Error>) -> Void in
            results.append(result)
        }

        scheduler.schedule("meow", completion: completion)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[optional: 0]?.success, "meow")

        // This schedule should be cancelled.
        scheduler.schedule("purr", completion: completion)
        // This schedule should use cache.
        scheduler.schedule("meow", completion: completion)

        XCTAssertEqual(performedCount, 1)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[optional: 1]?.failure as? SchedulerError, .cancelled)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[optional: 2]?.success, "meow")
    }

    func testContentFilterSchedulerShouldFailWithNotLatest() {
        var performedCount = 0
        var delayedPerformedCount = 0

        let scheduler = ContentFilterScheduler<String, String> { input, completion in
            performedCount += 1
            DispatchQueue.main.async {
                delayedPerformedCount += 1
                completion(.success(input))
            }
        }

        var results = [Result<String, Error>]()
        let completion = { (result: Result<String, Error>) -> Void in
            results.append(result)
        }

        XCTAssertEqual(performedCount, 0)
        XCTAssertEqual(delayedPerformedCount, 0)

        scheduler.schedule("meow", completion: completion)

        wait(for: RunLoop.main)

        XCTAssertEqual(performedCount, 1)
        // `DispatchQueue.main.async` is executed always later than `RunLoop.main.perform`.
        // At this moment, previous schedule completion is not called.
        XCTAssertEqual(delayedPerformedCount, 0)

        scheduler.schedule("purr", completion: completion)

        // This will wait both first and second schedule completions because
        // `DispatchQueue.main` is a serial queue.
        wait(for: DispatchQueue.main)

        XCTAssertEqual(performedCount, 2)
        XCTAssertEqual(delayedPerformedCount, 2)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[optional: 0]?.failure as? SchedulerError, .notLatest)
        XCTAssertEqual(results[optional: 1]?.success, "purr")
    }
}
