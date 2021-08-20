//
//  TextEditorViewTextInputTraits.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

/// :nodoc:
extension TextEditorView: UITextInputTraits {
    public var autocapitalizationType: UITextAutocapitalizationType {
        get {
            textView.autocapitalizationType
        }
        set {
            textView.autocapitalizationType = newValue
        }
    }

    public var autocorrectionType: UITextAutocorrectionType {
        get {
            textView.autocorrectionType
        }
        set {
            textView.autocorrectionType = newValue
        }
    }

    public var spellCheckingType: UITextSpellCheckingType {
        get {
            textView.spellCheckingType
        }
        set {
            textView.spellCheckingType = newValue
        }
    }

    public var smartQuotesType: UITextSmartQuotesType {
        get {
            textView.smartQuotesType
        }
        set {
            textView.smartQuotesType = newValue
        }
    }

    public var smartDashesType: UITextSmartDashesType {
        get {
            textView.smartDashesType
        }
        set {
            textView.smartDashesType = newValue
        }
    }

    public var smartInsertDeleteType: UITextSmartInsertDeleteType {
        get {
            textView.smartInsertDeleteType
        }
        set {
            textView.smartInsertDeleteType = newValue
        }
    }

    public var keyboardType: UIKeyboardType {
        get {
            textView.keyboardType
        }
        set {
            textView.keyboardType = newValue
        }
    }

    public var keyboardAppearance: UIKeyboardAppearance {
        get {
            textView.keyboardAppearance
        }
        set {
            textView.keyboardAppearance = newValue
        }
    }

    public var returnKeyType: UIReturnKeyType {
        get {
            textView.returnKeyType
        }
        set {
            textView.returnKeyType = newValue
        }
    }

    public var enablesReturnKeyAutomatically: Bool {
        get {
            textView.enablesReturnKeyAutomatically
        }
        set {
            textView.enablesReturnKeyAutomatically = newValue
        }
    }

    public var isSecureTextEntry: Bool {
        get {
            textView.isSecureTextEntry
        }
        set {
            textView.isSecureTextEntry = newValue
        }
    }

    public var textContentType: UITextContentType! {
        get {
            textView.textContentType
        }
        set {
            textView.textContentType = newValue
        }
    }

    @available(iOS 12.0, *)
    public var passwordRules: UITextInputPasswordRules? {
        get {
            textView.passwordRules
        }
        set {
            textView.passwordRules = newValue
        }
    }
}
