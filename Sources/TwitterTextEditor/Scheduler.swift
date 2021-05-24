//
//  Scheduler.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/**
 A generic scheduling error.

 - SeeAlso:
   - `ContentFilterScheduler`
 */
enum SchedulerError: Error {
    /**
     The schedule is cancelled because it scheduled a new one.
     */
    case cancelled
    /**
     The schedule is executed but the output is obsoleted because the new one is scheduled.
     */
    case notLatest
}

/**
 A scheduler that execute a block once each call on the main run loop, or
 execute immediately at the specific timing.

 Useful to debounce user interface events delegate callbacks.
 See `__CFRunLoopRun(...)` about the execution timing.

 - SeeAlso:
   - `__CFRunLoopRun(...)`
 */
final class DebounceScheduler {
    typealias Block = () -> Void

    private let block: Block

    /**
     Initialize with a block.

     - Parameters:
       - block: a block called from each call on the main run loop if it's scheduled.
     */
    init(_ block: @escaping Block) {
        self.block = block
    }

    private var isScheduled: Bool = false

    /**
     Schedule calling the block.
     */
    func schedule() {
        guard !isScheduled else {
            log(type: .debug, "Already scheduled.")
            return
        }
        isScheduled = true

        RunLoop.main.perform {
            guard self.isScheduled else {
                log(type: .debug, "Already performed.")
                return
            }
            self.perform()
        }
    }

    /**
     Immediately call the block.
     */
    func perform() {
        isScheduled = false
        block()
    }
}

/**
 A scheduler that executes an asynchronous filter once each call on the main run loop
 and caches the immediate previous call also ignores any previous results of the asynchronous filter.

 Useful to execute idempotent filter repeatedly to the input value and eventually get the latest output.
 See `__CFRunLoopRun(...)` about the execution timing.

 - SeeAlso:
   - `__CFRunLoopRun(...)`
 */
final class ContentFilterScheduler<Input: Equatable, Output> {
    typealias Completion = (Result<Output, Error>) -> Void
    typealias Filter = (Input, @escaping Completion) -> Void

    private let filter: Filter

    /**
     Initialize with a filter block.

     - Parameters:
       - filter: a block to asynchronously filter `Input` and call `Completion` with `Result<Output, Error>`.
         It's callers responsibility to call `Completion` or scheduled filtering will never end.
     */
    init(filter: @escaping Filter) {
        self.filter = filter
    }

    private struct Schedule {
        var input: Input
        var completion: Completion
    }

    private struct Cache {
        var key: Input
        var value: Output
    }

    private var schedule: Schedule?
    private var cache: Cache?
    private var latestToken: NSObject?

    /**
     Schedule a filtering.

     - Parameters:
       - input: An `Input` to be filtered.
       - completion: A block that is called with `Result<Output, Error>` when the asynchronous filtering.
         `Error` can be one of `SchedulerError` if the schedule is cancelled or there is newer schedule.

     - SeeAlso:
       - `SchedulerError`
     */
    func schedule(_ input: Input, completion: @escaping Completion) {
        let previousSchedule = schedule
        schedule = Schedule(input: input, completion: completion)

        // Debounce
        if let previousSchedule = previousSchedule {
            log(type: .debug, "Cancelled")
            previousSchedule.completion(.failure(SchedulerError.cancelled))
            return
        }

        RunLoop.main.perform {
            guard let schedule = self.schedule else {
                assertionFailure()
                return
            }
            self.schedule = nil

            // Cache
            if let cache = self.cache, cache.key == schedule.input {
                log(type: .debug, "Use cache")
                schedule.completion(.success(cache.value))
                return
            }

            // Latest
            let token = NSObject()
            self.latestToken = token

            self.filter(schedule.input) { [weak self] result in
                guard let self = self else {
                    return
                }

                guard let latestToken = self.latestToken, latestToken == token else {
                    log(type: .debug, "Not latest")
                    completion(.failure(SchedulerError.notLatest))
                    return
                }

                if case let .success(output) = result {
                    self.cache = Cache(key: schedule.input, value: output)
                }

                schedule.completion(result)
            }
        }
    }
}
