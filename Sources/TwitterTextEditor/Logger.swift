//
//  Logger.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

/**
 Logging levels supported by `Logger`.

 Compatible with `OSLogType`.

 - SeeAlso:
   - `OSLogType`
 */
public enum LogType {
    /**
     Default messages.
     */
    case `default`
    /**
     Informational messages.
     */
    case info
    /**
     Debug messages.
     */
    case debug
    /**
     Error condition messages.
     */
    case error
    /**
     Unexpected condition messages.
     */
    case fault
}

/**
 Logging interface used in this module.
 */
public protocol Logger {
    /**
     Method for logging.

     - Parameters:
       - type: Type of log.
       - file: Source file path to the logging position.
       - line: Line to the logging position in the `file`.
       - function: Function name of the logging position.
       - message: Log message.
     */
    func log(type: LogType,
             file: StaticString,
             line: Int,
             function: StaticString,
             message: @autoclosure () -> String?)
}

/**
 Default logging function.

 - Parameters:
   - type: Type of log.
   - file: Source file path to the logging position. Default to `#file`.
   - line: Line to the logging position in the `file`. Default to `#line`
   - function: Function name of the logging position. Default to `#function`.
   - message: Log message. Default to `nil`.
 */
func log(type: LogType,
         file: StaticString = #file,
         line: Int = #line,
         function: StaticString = #function,
         _ message: @autoclosure () -> String? = nil)
{
    guard let logger = Configuration.shared.logger else {
        return
    }

    logger.log(type: type,
               file: file,
               line: line,
               function: function,
               message: message())
}

/**
 Logging function with format.

 - Parameters:
   - type: Type of log.
   - file: Source file path to the logging position. Default to `#file`.
   - line: Line to the logging position in the `file`. Default to `#line`
   - function: Function name of the logging position. Default to `#function`.
   - format: Log message format.
   - arguments: Arguments for `format`.
 */
func log(type: LogType,
         file: StaticString = #file,
         line: Int = #line,
         function: StaticString = #function,
         _ format: String? = nil,
         _ arguments: CVarArg...)
{
    log(type: type,
        file: file,
        line: line,
        function: function,
        format.map { String(format: $0, arguments: arguments) })
}

/**
 A wrapper that provides custom descriptions to an arbitrary item for logging.

 This is intentionally `NSObject` to conform `CVarArg`.
 */
final class CustomDescribing<T>: NSObject {
    let item: T
    let describe: (T) -> String

    init(_ item: T, describe: @escaping (T) -> String) {
        self.item = item
        self.describe = describe
    }

    override var description: String {
        describe(item)
    }

    override var debugDescription: String {
        describe(item)
    }
}
