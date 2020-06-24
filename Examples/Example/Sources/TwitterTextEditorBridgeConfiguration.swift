//
//  TwitterTextEditorBridgeConfiguration.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import TwitterTextEditor

/**
 This is an example of how we can configure Twitter Text Editor from Objective-C.
 */
@objc
final class TwitterTextEditorBridgeConfiguration: NSObject {
    let configuration: Configuration

    @objc(sharedConfiguration)
    static func shared() -> Self {
        Self(configuration: TwitterTextEditor.Configuration.shared)
    }

    init(configuration: Configuration) {
        self.configuration = configuration
        super.init()
    }

    @objc
    var logger: TwitterTextEditorLogger? {
        get {
            if let loggerWrapper = configuration.logger as? LoggerWrapper {
                return loggerWrapper.logger
            }
            return nil
        }
        set {
            configuration.logger = newValue.map { LoggerWrapper(logger: $0) }
        }
    }

    @objc
    var tracer: TwitterTextEditorTracer? {
        get {
            if let tracerWrapper = configuration.tracer as? TracerWrapper {
                return tracerWrapper.tracer
            }
            return nil
        }
        set {
            configuration.tracer = newValue.map { TracerWrapper(tracer: $0) }
        }
    }

    @objc
    var isDebugLayoutManagerDrawGlyphsEnabled: Bool {
        get {
            configuration.isDebugLayoutManagerDrawGlyphsEnabled
        }
        set {
            configuration.isDebugLayoutManagerDrawGlyphsEnabled = newValue
        }
    }
}

// MARK: - Logger

@objc
enum TwitterTextEditorLogType: Int {
    case `default` = 0
    case info
    case debug
    case error
    case fault
}

@objc
protocol TwitterTextEditorLogger {
    @objc
    func log(type: TwitterTextEditorLogType,
             file: String,
             line: Int,
             function: String,
             message: String?)
}

private extension TwitterTextEditor.LogType {
    var logType: TwitterTextEditorLogType {
        switch self {
        case .default:
            return .default
        case .info:
            return .info
        case .debug:
            return .debug
        case .error:
            return .error
        case .fault:
            return .fault
        }
    }
}

private struct LoggerWrapper: TwitterTextEditor.Logger {
    @usableFromInline
    var logger: TwitterTextEditorLogger

    @inlinable
    func log(type: TwitterTextEditor.LogType,
             file: StaticString,
             line: Int,
             function: StaticString,
             message: @autoclosure () -> String?)
    {
        logger.log(type: type.logType,
                   file: String(describing: file),
                   line: line,
                   function: String(describing: function),
                   message: message())
    }
}

// MARK: - Tracer

@objc
protocol TwitterTextEditorSignpost {
    func begin()
    func end()
    func event()
}

private struct SignpostWrapper: TwitterTextEditor.Signpost {
    @usableFromInline
    var signpost: TwitterTextEditorSignpost

    @inlinable
    func begin() {
        signpost.begin()
    }

    @inlinable
    func end() {
        signpost.end()
    }

    @inlinable
    func event() {
        signpost.event()
    }
}

@objc
protocol TwitterTextEditorTracer {
    @objc
    func signpost(name: String,
                  file: String,
                  line: Int,
                  function: String,
                  message: String?) -> TwitterTextEditorSignpost
}

private struct TracerWrapper: TwitterTextEditor.Tracer {
    @usableFromInline
    var tracer: TwitterTextEditorTracer

    @inlinable
    func signpost(name: StaticString,
                  file: StaticString,
                  line: Int,
                  function: StaticString,
                  message: @autoclosure () -> String?) -> TwitterTextEditor.Signpost
    {
        let signpost = tracer.signpost(name: String(describing: name),
                                       file: String(describing: name),
                                       line: line,
                                       function: String(describing: name),
                                       message: message())
        return SignpostWrapper(signpost: signpost)
    }
}
