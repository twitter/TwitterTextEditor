//
//  UIResponder.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

extension UIResponder {
    /**
     Returns if the responder is using dictation or not.

     - SeeAlso:
       - `UITextInput.hasMarkedText`
     */
    var isDictationRecording: Bool {
        // TODO: Probably need to take an account of `preferredTextInputModePrimaryLanguage`.
        textInputMode?.primaryLanguage == "dictation"
    }
}
