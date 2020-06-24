//
//  OSLog.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import TwitterTextEditor
import os

struct OSDefaultLogger: TwitterTextEditor.Logger {
    func log(type: TwitterTextEditor.LogType,
             file: StaticString,
             line: Int,
             function: StaticString,
             message: @autoclosure () -> String?)
    {
        let osLogType: OSLogType
        switch type {
        case .`default`:
            osLogType = .default
        case .info:
            osLogType = .info
        case .debug:
            osLogType = .debug
        case .error:
            osLogType = .error
        case .fault:
            osLogType = .fault
        }

        if let message = message() {
            os_log("%{public}@:%d in %{public}@: %{public}@",
                   type: osLogType,
                   NSString(stringLiteral: file).lastPathComponent, // swiftlint:disable:this compiler_protocol_init
                   line, String(describing: function),
                   message)
        } else {
            os_log("%{public}@:%d in %{public}@",
                   type: osLogType,
                   NSString(stringLiteral: file).lastPathComponent, // swiftlint:disable:this compiler_protocol_init
                   line,
                   String(describing: function))
        }
    }
}

struct OSSignpost: TwitterTextEditor.Signpost {
    // TODO: Remove `os_signpost` wrapper when it drops iOS 11 support.
    @available(iOS 12.0, *)
    private struct OSSignpost: TwitterTextEditor.Signpost {
        private let log: OSLog
        private let name: StaticString
        private let message: String?

        private let signpostID: OSSignpostID

        init(log: OSLog,
             name: StaticString,
             message: String? = nil)
        {
            self.log = log
            self.name = name
            self.message = message

            signpostID = OSSignpostID(log: log)
        }

        private func signpost(_ type: OSSignpostType) {
            if let message = message {
                os_signpost(type, log: log, name: name, signpostID: signpostID, "%@", message)
            } else {
                os_signpost(type, log: log, name: name, signpostID: signpostID)
            }
        }

        func begin() {
            signpost(.begin)
        }

        func end() {
            signpost(.end)
        }

        func event() {
            signpost(.event)
        }
    }

    private let signpost: TwitterTextEditor.Signpost?

    init(log: OSLog,
         name: StaticString,
         message: String? = nil)
    {
        if #available(iOS 12.0, *) {
            signpost = OSSignpost(log: log, name: name, message: message)
        } else {
            signpost = nil
        }
    }

    func begin() {
        signpost?.begin()
    }

    func end() {
        signpost?.end()
    }

    func event() {
        signpost?.event()
    }
}

struct OSDefaultTracer: TwitterTextEditor.Tracer {
    func signpost(name: StaticString,
                  file: StaticString,
                  line: Int,
                  function: StaticString,
                  message: @autoclosure () -> String?) -> TwitterTextEditor.Signpost
    {
        OSSignpost(log: .default, name: name, message: message())
    }
}
