//
//  EditingContent.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct EditingContent: Equatable {
    enum InitializeError: Error {
        case outOfSelectedRange(validRange: NSRange)
    }

    var text: String
    var selectedRange: NSRange

    init(text: String, selectedRange: NSRange) throws {
        guard text.range.contains(selectedRange) else {
            throw InitializeError.outOfSelectedRange(validRange: text.range)
        }

        self.text = text
        self.selectedRange = selectedRange
    }

    // MARK: -

    enum UpdateError: Error {
        case outOfReplacingRange(validRange: NSRange)
    }

    struct UpdateRequest {
        var replacingRange: NSRange?
        var replacingText: String?
        var selectedRange: NSRange?

        static let null = Self(replacingRange: nil, replacingText: nil, selectedRange: nil)

        static func text(_ text: String, selectedRange: NSRange? = nil) -> Self {
            .init(replacingRange: nil, replacingText: text, selectedRange: selectedRange)
        }

        static func subtext(range: NSRange, text: String, selectedRange: NSRange? = nil) -> Self {
            .init(replacingRange: range, replacingText: text, selectedRange: selectedRange)
        }

        static func selectedRange(_ selectedRange: NSRange) -> Self {
            .init(replacingRange: nil, replacingText: nil, selectedRange: selectedRange)
        }
    }

    func update(with request: UpdateRequest) throws -> EditingContent {
        let updatedText: String
        let updatedSelectedRange: NSRange

        if let replacingText = request.replacingText {
            let textRange = text.range
            let replacingRange = request.replacingRange ?? textRange
            guard textRange.contains(replacingRange) else {
                throw UpdateError.outOfReplacingRange(validRange: textRange)
            }

            updatedText = text.replacingCharacters(in: replacingRange, with: replacingText)
            updatedSelectedRange = request.selectedRange ?? selectedRange.movedByReplacing(range: replacingRange, length: replacingText.length)
        } else {
            updatedText = text
            updatedSelectedRange = request.selectedRange ?? selectedRange
        }

        return try EditingContent(text: updatedText, selectedRange: updatedSelectedRange)
    }

    // MARK: -

    struct ChangeResult: Equatable {
        var isTextChanged: Bool
        var isSelectedRangeChanged: Bool
    }

    func changeResult(from content: EditingContent) -> ChangeResult? {
        switch ((text != content.text), (selectedRange != content.selectedRange)) {
        case (false, false):
            return nil
        case (let isTextChanged, let isSelectedRangeChanged):
            return ChangeResult(isTextChanged: isTextChanged, isSelectedRangeChanged: isSelectedRangeChanged)
        }
    }
}
