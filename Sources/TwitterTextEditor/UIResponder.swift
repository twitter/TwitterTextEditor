//
//  UIResponder.swift
//  TwitterTextEditor
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
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
