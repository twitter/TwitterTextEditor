//
//  TextEditorViewTextInputTraits.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

extension TextEditorView: UITextInputTraits {
    /// :nodoc:
    public var autocapitalizationType: UITextAutocapitalizationType {
        get {
            textView.autocapitalizationType
        }
        set {
            textView.autocapitalizationType = newValue
        }
    }

    /// :nodoc:
    public var autocorrectionType: UITextAutocorrectionType {
        get {
            textView.autocorrectionType
        }
        set {
            textView.autocorrectionType = newValue
        }
    }

    /// :nodoc:
    public var spellCheckingType: UITextSpellCheckingType {
        get {
            textView.spellCheckingType
        }
        set {
            textView.spellCheckingType = newValue
        }
    }

    /// :nodoc:
    public var smartQuotesType: UITextSmartQuotesType {
        get {
            textView.smartQuotesType
        }
        set {
            textView.smartQuotesType = newValue
        }
    }

    /// :nodoc:
    public var smartDashesType: UITextSmartDashesType {
        get {
            textView.smartDashesType
        }
        set {
            textView.smartDashesType = newValue
        }
    }

    /// :nodoc:
    public var smartInsertDeleteType: UITextSmartInsertDeleteType {
        get {
            textView.smartInsertDeleteType
        }
        set {
            textView.smartInsertDeleteType = newValue
        }
    }

    /// :nodoc:
    public var keyboardType: UIKeyboardType {
        get {
            textView.keyboardType
        }
        set {
            textView.keyboardType = newValue
        }
    }

    /// :nodoc:
    public var keyboardAppearance: UIKeyboardAppearance {
        get {
            textView.keyboardAppearance
        }
        set {
            textView.keyboardAppearance = newValue
        }
    }

    /// :nodoc:
    public var returnKeyType: UIReturnKeyType {
        get {
            textView.returnKeyType
        }
        set {
            textView.returnKeyType = newValue
        }
    }

    /// :nodoc:
    public var enablesReturnKeyAutomatically: Bool {
        get {
            textView.enablesReturnKeyAutomatically
        }
        set {
            textView.enablesReturnKeyAutomatically = newValue
        }
    }

    /// :nodoc:
    public var isSecureTextEntry: Bool {
        get {
            textView.isSecureTextEntry
        }
        set {
            textView.isSecureTextEntry = newValue
        }
    }

    /// :nodoc:
    public var textContentType: UITextContentType! {
        get {
            textView.textContentType
        }
        set {
            textView.textContentType = newValue
        }
    }

    /// :nodoc:
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
