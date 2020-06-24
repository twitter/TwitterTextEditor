//
//  Tracer.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

import Foundation

/**
 A signpost interface used in this module.

 Compatible with `OSSignpostType`.

 - SeeAlso:
   - `OSSignpostType`
 */
public protocol Signpost {
    /**
     Marks the start of a time interval of the tracing.
     */
    func begin()

    /**
     Marks the end of a time interval of the tracing.
     */
    func end()

    /**
     Marks an event of the tracing.
     */
    func event()
}

/**
 A tracing interface that creates a new `Signpost`.
 */
public protocol Tracer {
    /**
     Create a new signpost with message for tracing.

     - Parameters:
       - name: Name of signpost.
       - file: Source file path to the logging position.
       - line: Line to the logging position in the `file`.
       - function: Function name of the logging position.
       - message: Log message.

     - Returns: A new `Signpost` for the tracing.
     */
    func signpost(name: StaticString,
                  file: StaticString,
                  line: Int,
                  function: StaticString,
                  message: @autoclosure () -> String?) -> Signpost
}

private struct NoSignpost: Signpost {
    func begin() {
    }

    func end() {
    }

    func event() {
    }
}

/**
 Default function to create a signpost.

 - Parameters:
   - name: Name of signpost.
   - file: Source file path to the logging position. Default to `#file`.
   - line: Line to the logging position in the `file`. Default to `#line`
   - function: Function name of the logging position. Default to `#function`.
   - message: Log message. Default to `nil`.

 - Returns: A `Signpost` for the tracing.
*/
func signpost(name: StaticString,
              file: StaticString = #file,
              line: Int = #line,
              function: StaticString = #function,
              _ message: @autoclosure () -> String? = nil) -> Signpost
{
    guard let tracer = Configuration.shared.tracer else {
        return NoSignpost()
    }

    return tracer.signpost(name: name,
                           file: file,
                           line: line,
                           function: function,
                           message: message())
}

/**
  Create a signpost with a format.

 - Parameters:
   - name: Name of signpost.
   - file: Source file path to the logging position. Default to `#file`.
   - line: Line to the logging position in the `file`. Default to `#line`
   - function: Function name of the logging position. Default to `#function`.
   - format: Log message format.
   - arguments: Arguments for `format`.

 - Returns: A `Signpost` for the tracing.
 */
func signpost(name: StaticString,
              file: StaticString = #file,
              line: Int = #line,
              function: StaticString = #function,
              _ format: String? = nil,
              _ arguments: CVarArg...) -> Signpost
{
    signpost(name: name,
             file: file,
             line: line,
             function: function,
             format.map { String(format: $0, arguments: arguments) })
}
