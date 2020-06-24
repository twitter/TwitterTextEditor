//
//  UITextInput.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

extension UITextInput {
    /**
     Returns if the text input has marked text or not.

     - SeeAlso:
       - `UIResponder.isDictationRecording`
     */
    var hasMarkedText: Bool {
        markedTextRange != nil
    }

    /**
     Returns a rect of caret at the beginning of the current selected range.
     Useful to find the current cursor position.

     `nil` if there is no selected range.
     */
    var caretRectAtBeginningOfSelectedRange: CGRect? {
        guard let selectedTextRange = selectedTextRange else {
            return nil
        }

        return caretRect(for: selectedTextRange.start)
    }

    /**
     Returns a rect of caret at the end of the current selected range.
     Useful to find the current cursor position.

     `nil` if there is no selected range.
     */
    var caretRectAtEndOfSelectedRange: CGRect? {
        guard let selectedTextRange = selectedTextRange else {
            return nil
        }

        return caretRect(for: selectedTextRange.end)
    }

    /**
     Returns a rect used for presenting a menu which has items such as copy and paste
     for the current selected range.
     Useful to present a menu manually.

     `nil` if there is no selected range.
     */
    var menuRectAtSelectedRange: CGRect? {
        guard let selectedTextRange = selectedTextRange else {
            return nil
        }

        let selectedRangeLength = offset(from: selectedTextRange.start, to: selectedTextRange.end)
        if selectedRangeLength > 0 {
            // The menu is by default appearing at the middle of first rect of selected range.
            return firstRect(for: selectedTextRange)
        } else {
            // The menu is by default appearing at the caret position.
            return caretRect(for: selectedTextRange.start)
        }
    }
}
